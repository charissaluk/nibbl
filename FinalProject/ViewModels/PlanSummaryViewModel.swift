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

    let session: PlanningSession

    init(
        session: PlanningSession,
        likedRecommendations: [RecommendationResult]
    ) {
        self.session = session
        buildSummary(from: likedRecommendations)
    }

    func createReservationPlaceholder(
        for item: SummaryItem,
        context: ModelContext
    ) {
        let reservation = Reservation(
            restaurantID: item.restaurant.id,
            planningSessionID: session.id,
            reservationDate: Date().addingTimeInterval(60 * 60 * 24 * 3),
            status: "draft"
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
        let sorted = likedRecommendations.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.restaurant.name < rhs.restaurant.name
            }
            return lhs.score > rhs.score
        }

        let mapped = sorted.map { result in
            let percentage = displayMatchPercentage(for: result)
            let explanation = explanationLines(for: result)

            return SummaryItem(
                id: result.restaurant.id,
                restaurant: result.restaurant,
                matchPercentage: percentage,
                score: result.score,
                explanationLines: explanation
            )
        }

        rankedMatches = mapped
        topMatch = mapped.first
    }

    private func displayMatchPercentage(for result: RecommendationResult) -> Int {
        let restaurant = result.restaurant

        let cuisineMatched: Bool = {
            guard !session.selectedCuisineFilters.isEmpty else { return true }
            return session.selectedCuisineFilters.contains {
                $0.caseInsensitiveCompare(restaurant.cuisine) == .orderedSame
            }
        }()

        let priceMatched = PriceTierHelper.isWithinRange(
            restaurant.priceTier,
            min: session.minPriceTier,
            max: session.maxPriceTier
        )

        let distanceMatched: Bool = {
            guard let distance = restaurant.distanceFromUser else { return true }
            return distance <= session.maxDistanceMiles
        }()

        let isGroupMode = session.mode == "group"

        if !isGroupMode {
            if cuisineMatched && priceMatched && distanceMatched {
                return 100
            }

            var percentage = 0
            if cuisineMatched { percentage += 40 }
            if priceMatched { percentage += 35 }
            if distanceMatched { percentage += 25 }

            return min(100, max(0, percentage))
        } else {
            var percentage = 0
            if cuisineMatched { percentage += 30 }
            if priceMatched { percentage += 25 }
            if distanceMatched { percentage += 20 }

            let averageFriendFit: Double = {
                guard !result.friendCompatibility.isEmpty else { return 1.0 }
                return result.friendCompatibility.values.reduce(0, +) / Double(result.friendCompatibility.count)
            }()

            percentage += Int((averageFriendFit * 25).rounded())

            if cuisineMatched && priceMatched && distanceMatched {
                percentage = max(percentage, 85)
            }

            return min(100, max(0, percentage))
        }
    }

    private func explanationLines(for result: RecommendationResult) -> [String] {
        let restaurant = result.restaurant
        var lines: [String] = []

        let cuisineMatched: Bool = {
            guard !session.selectedCuisineFilters.isEmpty else { return true }
            return session.selectedCuisineFilters.contains {
                $0.caseInsensitiveCompare(restaurant.cuisine) == .orderedSame
            }
        }()

        let priceMatched = PriceTierHelper.isWithinRange(
            restaurant.priceTier,
            min: session.minPriceTier,
            max: session.maxPriceTier
        )

        let distanceMatched: Bool = {
            guard let distance = restaurant.distanceFromUser else { return true }
            return distance <= session.maxDistanceMiles
        }()

        if cuisineMatched {
            lines.append("✓ Cuisine match")
        }

        if priceMatched {
            lines.append("✓ In your price range")
        }

        if distanceMatched {
            lines.append("✓ Within distance")
        }

        if session.mode == "group" {
            let averageFriendFit: Int = {
                guard !result.friendCompatibility.isEmpty else { return 100 }
                let avg = result.friendCompatibility.values.reduce(0, +) / Double(result.friendCompatibility.count)
                return Int((avg * 100).rounded())
            }()
            lines.append("Group fit: \(averageFriendFit)%")
        } else {
            lines.append("Strong overall fit for this plan")
        }

        return lines
    }
}
