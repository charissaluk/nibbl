//
//  SwipeDeckViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/22/26.
//
import Foundation
import SwiftData
import Combine
import OSLog

@MainActor
final class SwipeDeckViewModel: ObservableObject {
    @Published private(set) var recommendations: [RecommendationResult] = []
    @Published private(set) var currentIndex: Int = 0
    @Published private(set) var swipeDecisions: [SwipeDecision] = []
    @Published private(set) var hasFinished: Bool = false

    let session: PlanningSession

    private let recommendationEngine: RecommendationEngineServicing
    private let mockUserService: MockUserServicing
    private let hapticsService: HapticsServicing
    private let logger = Logger(subsystem: "Nibbl", category: "Planning")

    convenience init(
        session: PlanningSession,
        candidateRestaurants: [Restaurant]
    ) {
        self.init(
            session: session,
            candidateRestaurants: candidateRestaurants,
            recommendationEngine: RecommendationEngine(),
            mockUserService: MockUserService(),
            hapticsService: HapticsService()
        )
    }

    init(
        session: PlanningSession,
        candidateRestaurants: [Restaurant],
        recommendationEngine: RecommendationEngineServicing,
        mockUserService: MockUserServicing,
        hapticsService: HapticsServicing
    ) {
        self.session = session
        self.recommendationEngine = recommendationEngine
        self.mockUserService = mockUserService
        self.hapticsService = hapticsService

        let selectedFriends = mockUserService.fetchUsers(withIDs: session.selectedFriendIDs)

        let filters = FilterSettings(
            cuisines: session.selectedCuisineFilters,
            minPrice: session.minPriceTier,
            maxPrice: session.maxPriceTier,
            maxDistanceMiles: session.maxDistanceMiles,
            minimumRating: 0
        )

        self.recommendations = recommendationEngine.rankRestaurants(
            candidates: candidateRestaurants,
            currentUserFilters: filters,
            selectedFriends: selectedFriends,
            transportMode: session.transportMode
        )
    }

    var currentRecommendation: RecommendationResult? {
        guard currentIndex < recommendations.count else { return nil }
        return recommendations[currentIndex]
    }

    var remainingCount: Int {
        max(recommendations.count - currentIndex, 0)
    }

    var likedRecommendations: [RecommendationResult] {
        let likedIDs = Set(
            swipeDecisions
                .filter { $0.decision == "like" }
                .map(\.restaurantID)
        )

        return recommendations.filter { likedIDs.contains($0.restaurant.id) }
    }

    func recordSwipe(
        direction: SwipeDirection,
        context: ModelContext
    ) {
        guard let currentRecommendation else { return }

        let decisionValue = direction == .right ? "like" : "pass"

        let swipeDecision = SwipeDecision(
            sessionID: session.id,
            restaurantID: currentRecommendation.restaurant.id,
            decision: decisionValue
        )

        context.insert(swipeDecision)

        do {
            try context.save()
        } catch {
            logger.error("Failed to save swipe decision: \(error.localizedDescription, privacy: .public)")
        }

        swipeDecisions.append(swipeDecision)

        if direction == .right {
            hapticsService.notifySuccess()
        } else {
            hapticsService.impactRigid()
        }

        currentIndex += 1

        if currentIndex >= recommendations.count {
            hasFinished = true
        }
    }

    func markFinishedIfNeeded() {
        if recommendations.isEmpty || currentIndex >= recommendations.count {
            hasFinished = true
        }
    }

    func displayMatchPercentage(for result: RecommendationResult) -> Int {
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

        if session.mode != "group" {
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

    func explanationLines(for result: RecommendationResult) -> [String] {
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

        if lines.isEmpty {
            lines.append("Strong candidate for this plan")
        }

        return lines
    }
}

enum SwipeDirection {
    case left
    case right
}
