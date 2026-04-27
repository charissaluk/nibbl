//
//  PlanSummaryViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/20/26.
//
import Foundation
import SwiftData
import Combine

final class PlanSummaryViewModel: ObservableObject {
    struct SummaryItem: Identifiable, Hashable {
        let id: UUID
        let restaurant: Restaurant
        let matchPercentage: Int
        let score: Double
        let explanationLines: [String]
    }

    @Published private(set) var rankedMatches: [SummaryItem] = []
    @Published private(set) var topMatch: SummaryItem?
    @Published private(set) var reservationMessage: String?

    private var session: PlanningSession?
    private var savedRestaurants: [Restaurant] = []

    init() {}

    func configure(
        session: PlanningSession,
        likedRecommendations: [RecommendationResult],
        savedRestaurants: [Restaurant]
    ) {
        self.session = session
        self.savedRestaurants = savedRestaurants
        buildSummary(from: likedRecommendations)
    }

    func createReservationPlaceholder(
        for item: SummaryItem,
        context: ModelContext
    ) {
        guard let session else { return }

        let acceptsReservations = MockReservationBackend.acceptsReservations(for: item.restaurant)
        let defaultMessages = MockReservationBackend.defaultMessages(for: session.mode)

        let reservation = Reservation(
            restaurantID: item.restaurant.id,
            planningSessionID: session.id,
            restaurantName: item.restaurant.name,
            restaurantCuisine: item.restaurant.cuisine,
            restaurantAddress: item.restaurant.address,
            restaurantLatitude: item.restaurant.latitude,
            restaurantLongitude: item.restaurant.longitude,
            mode: session.mode == "group" ? "group" : "individual",
            reservationDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
            status: "draft",
            acceptsReservations: acceptsReservations,
            bookingProvider: MockReservationBackend.providerName(for: item.restaurant),
            bookingURLString: MockReservationBackend.bookingURLString(for: item.restaurant),
            messages: defaultMessages
        )

        context.insert(reservation)

        do {
            try context.save()
            reservationMessage = "Draft reservation created for \(item.restaurant.name)."
        } catch {
            reservationMessage = "Could not create reservation placeholder."
        }
    }

    private func buildSummary(from likedRecommendations: [RecommendationResult]) {
        let mapped = likedRecommendations.map { result in
            let percentage = displayMatchPercentage(for: result)
            let explanation = explanationLines(for: result)

            return SummaryItem(
                id: result.restaurant.id,
                restaurant: result.restaurant,
                matchPercentage: percentage,
                score: Double(percentage) / 100.0,
                explanationLines: explanation
            )
        }
        .sorted { lhs, rhs in
            if lhs.matchPercentage == rhs.matchPercentage {
                return lhs.restaurant.name < rhs.restaurant.name
            }
            return lhs.matchPercentage > rhs.matchPercentage
        }

        rankedMatches = mapped
        topMatch = mapped.first
    }

    private func displayMatchPercentage(for result: RecommendationResult) -> Int {
        guard let session else { return 0 }

        let restaurant = result.restaurant
        let savedCuisineScore = savedCuisineSimilarity(for: restaurant)
        let savedPriceScore = savedPriceSimilarity(for: restaurant)
        let filterScore = currentFilterScore(for: restaurant, session: session)
        let distanceScore = distanceScore(for: restaurant, session: session)

        if session.mode == "group" {
            let friendScore: Double = {
                guard !result.friendCompatibility.isEmpty else { return 0.75 }
                return result.friendCompatibility.values.reduce(0, +) / Double(result.friendCompatibility.count)
            }()

            let finalScore =
                (savedCuisineScore * 0.25) +
                (savedPriceScore * 0.10) +
                (friendScore * 0.35) +
                (filterScore * 0.20) +
                (distanceScore * 0.10)

            return Int((finalScore * 100).rounded())
        } else {
            let finalScore =
                (savedCuisineScore * 0.40) +
                (savedPriceScore * 0.25) +
                (filterScore * 0.20) +
                (distanceScore * 0.15)

            return Int((finalScore * 100).rounded())
        }
    }

    private func savedCuisineSimilarity(for restaurant: Restaurant) -> Double {
        guard !savedRestaurants.isEmpty else { return 0.65 }

        let candidateCuisines = cuisineTokens(from: restaurant.cuisine)
        let savedCuisineTokens = savedRestaurants.flatMap {
            cuisineTokens(from: $0.cuisine)
        }

        guard !candidateCuisines.isEmpty, !savedCuisineTokens.isEmpty else {
            return 0.65
        }

        return candidateCuisines.contains(where: { savedCuisineTokens.contains($0) }) ? 1.0 : 0.35
    }

    private func savedPriceSimilarity(for restaurant: Restaurant) -> Double {
        guard !savedRestaurants.isEmpty else { return 0.65 }

        let candidatePrice = restaurant.priceTier.count
        let savedPrices = savedRestaurants.map { $0.priceTier.count }

        guard !savedPrices.isEmpty else { return 0.65 }

        let averageSavedPrice = Double(savedPrices.reduce(0, +)) / Double(savedPrices.count)
        let difference = abs(Double(candidatePrice) - averageSavedPrice)

        switch difference {
        case 0..<0.75:
            return 1.0
        case 0.75..<1.5:
            return 0.75
        case 1.5..<2.5:
            return 0.45
        default:
            return 0.20
        }
    }

    private func currentFilterScore(for restaurant: Restaurant, session: PlanningSession) -> Double {
        var score = 0.0
        var total = 0.0

        if !session.selectedCuisineFilters.isEmpty {
            total += 1
            let candidateCuisines = cuisineTokens(from: restaurant.cuisine)
            let filterCuisines = Set(session.selectedCuisineFilters.flatMap { cuisineTokens(from: $0) })

            if candidateCuisines.contains(where: { filterCuisines.contains($0) }) {
                score += 1
            }
        }

        total += 1
        if PriceTierHelper.isWithinRange(
            restaurant.priceTier,
            min: session.minPriceTier,
            max: session.maxPriceTier
        ) {
            score += 1
        }

        return total > 0 ? score / total : 1.0
    }

    private func distanceScore(for restaurant: Restaurant, session: PlanningSession) -> Double {
        guard let distance = restaurant.distanceFromUser else { return 0.75 }

        let ratio = distance / max(session.maxDistanceMiles, 0.1)

        switch ratio {
        case ...0.5:
            return 1.0
        case ...1.0:
            return 0.75
        case ...1.5:
            return 0.4
        default:
            return 0.15
        }
    }

    private func explanationLines(for result: RecommendationResult) -> [String] {
        guard let session else { return [] }

        let restaurant = result.restaurant
        var lines: [String] = []

        let savedCuisineScore = savedCuisineSimilarity(for: restaurant)
        let savedPriceScore = savedPriceSimilarity(for: restaurant)
        let filterScore = currentFilterScore(for: restaurant, session: session)
        let distance = distanceScore(for: restaurant, session: session)

        if savedCuisineScore >= 1.0 {
            lines.append("✓ Similar cuisine to your saved spots")
        } else if savedCuisineScore >= 0.65 {
            lines.append("✓ Balanced with your saved taste")
        }

        if savedPriceScore >= 0.75 {
            lines.append("✓ Similar price range to places you save")
        }

        if filterScore >= 0.75 {
            lines.append("✓ Matches your current filters")
        }

        if distance >= 0.75 {
            lines.append("✓ Convenient distance")
        }

        if session.mode == "group" {
            let averageFriendFit: Int = {
                guard !result.friendCompatibility.isEmpty else { return 75 }
                let avg = result.friendCompatibility.values.reduce(0, +) / Double(result.friendCompatibility.count)
                return Int((avg * 100).rounded())
            }()
            lines.append("Group fit: \(averageFriendFit)%")
        } else {
            lines.append("Based on your saved restaurants")
        }

        return lines
    }

    private func cuisineTokens(from cuisine: String) -> Set<String> {
        let tokens = cuisine
            .lowercased()
            .components(separatedBy: CharacterSet(charactersIn: ",/&+"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return Set(tokens)
    }
}
