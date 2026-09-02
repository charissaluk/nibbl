//
//  RecommendationResult.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation

struct RecommendationResult: Identifiable, Hashable {
    let id: UUID
    let restaurant: Restaurant
    let score: Double
    let friendCompatibility: [String: Double]

    init(
        restaurant: Restaurant,
        score: Double,
        friendCompatibility: [String: Double]
    ) {
        self.id = restaurant.id
        self.restaurant = restaurant
        self.score = score
        self.friendCompatibility = friendCompatibility
    }
}

protocol RecommendationEngineServicing {
    func rankRestaurants(
        candidates: [Restaurant],
        currentUserFilters: FilterSettings,
        selectedFriends: [MockUserProfile],
        transportMode: String
    ) -> [RecommendationResult]
}

struct RecommendationEngine: RecommendationEngineServicing {
    func rankRestaurants(
        candidates: [Restaurant],
        currentUserFilters: FilterSettings,
        selectedFriends: [MockUserProfile],
        transportMode: String
    ) -> [RecommendationResult] {
        let hardCap = RecommendationScoring.hardDistanceCap(for: transportMode)

        let filteredCandidates = candidates.filter { restaurant in
            RecommendationScoring.passesHardFilters(
                restaurant: restaurant,
                filters: currentUserFilters,
                hardDistanceCap: hardCap
            )
        }

        let ranked = filteredCandidates.map { restaurant in
            let currentUserScore = RecommendationScoring.scoreForCurrentUser(
                restaurant: restaurant,
                filters: currentUserFilters
            )

            let friendScores = Dictionary(uniqueKeysWithValues: selectedFriends.map { friend in
                (friend.id, RecommendationScoring.scoreForFriend(restaurant: restaurant, friend: friend))
            })

            let groupScore: Double
            if selectedFriends.isEmpty {
                groupScore = currentUserScore
            } else {
                groupScore = friendScores.values.reduce(0, +) / Double(friendScores.count)
            }

            let savedBoost = restaurant.isSaved ? 1.0 : 0.0

            let finalScore = (groupScore * 0.55) + (currentUserScore * 0.35) + (savedBoost * 0.10)

            return RecommendationResult(
                restaurant: restaurant,
                score: finalScore,
                friendCompatibility: friendScores
            )
        }

        return ranked.sorted { lhs, rhs in
            if lhs.score == rhs.score {
                return lhs.restaurant.name < rhs.restaurant.name
            }
            return lhs.score > rhs.score
        }
    }
}

enum RecommendationScoring {
    static func passesHardFilters(
        restaurant: Restaurant,
        filters: FilterSettings,
        hardDistanceCap: Double
    ) -> Bool {
        if !filters.cuisines.isEmpty && !filters.cuisines.contains(where: {
            $0.caseInsensitiveCompare(restaurant.cuisine) == .orderedSame
        }) {
            return false
        }

        if !PriceTierHelper.isWithinRange(
            restaurant.priceTier,
            min: filters.minPrice,
            max: filters.maxPrice
        ) {
            return false
        }

        if let rating = restaurant.rating, rating < filters.minimumRating {
            return false
        }

        let distance = restaurant.distanceFromUser ?? 0
        if distance > min(filters.maxDistanceMiles, hardDistanceCap) {
            return false
        }

        return true
    }

    static func hardDistanceCap(for transportMode: String) -> Double {
        switch transportMode.lowercased() {
        case "walking":
            return 1.0
        case "transit":
            return 2.0
        case "driving":
            return 10.0
        default:
            return 10.0
        }
    }

    static func scoreForCurrentUser(
        restaurant: Restaurant,
        filters: FilterSettings
    ) -> Double {
        let cuisineScore = scoreCuisineMatch(
            restaurantCuisine: restaurant.cuisine,
            preferredCuisines: filters.cuisines
        )

        let budgetScore = PriceTierHelper.normalizedMatchScore(
            restaurant.priceTier,
            min: filters.minPrice,
            max: filters.maxPrice
        )

        let distanceScore = scoreDistance(distance: restaurant.distanceFromUser, idealMax: filters.maxDistanceMiles)
        let ratingScore = scoreRating(restaurant.rating)
        let vibeScore = scoreVibeMatch(notes: restaurant.notes, preferences: [])
        let savedScore = restaurant.isSaved ? 1.0 : 0.0

        return normalize(
            (cuisineScore * 0.35) +
            (budgetScore * 0.25) +
            (distanceScore * 0.20) +
            (savedScore * 0.08) +
            (ratingScore * 0.08) +
            (vibeScore * 0.04)
        )
    }

    static func scoreForFriend(
        restaurant: Restaurant,
        friend: MockUserProfile
    ) -> Double {
        let cuisineScore = scoreCuisineMatch(
            restaurantCuisine: restaurant.cuisine,
            preferredCuisines: friend.preferredCuisines
        )

        let budgetScore = PriceTierHelper.normalizedMatchScore(
            restaurant.priceTier,
            min: friend.minPrice,
            max: friend.maxPrice
        )

        let distanceScore = scoreDistance(
            distance: restaurant.distanceFromUser,
            idealMax: friend.distanceToleranceMiles
        )

        let ratingScore = scoreRating(restaurant.rating)
        let vibeScore = scoreVibeMatch(notes: restaurant.notes, preferences: friend.vibePreferences)
        let savedScore = restaurant.isSaved ? friend.savedRestaurantBoost : 0

        return normalize(
            (cuisineScore * 0.40) +
            (budgetScore * 0.23) +
            (distanceScore * 0.18) +
            (savedScore * 0.08) +
            (ratingScore * 0.07) +
            (vibeScore * 0.04)
        )
    }

    static func scoreCuisineMatch(
        restaurantCuisine: String,
        preferredCuisines: [String]
    ) -> Double {
        guard !preferredCuisines.isEmpty else { return 0.75 }

        return preferredCuisines.contains(where: {
            $0.caseInsensitiveCompare(restaurantCuisine) == .orderedSame
        }) ? 1.0 : 0.15
    }

    static func scoreDistance(distance: Double?, idealMax: Double) -> Double {
        guard let distance else { return 0.75 }
        guard idealMax > 0 else { return 0.5 }

        let ratio = distance / idealMax

        switch ratio {
        case ...0.35:
            return 1.0
        case ...0.75:
            return 0.85
        case ...1.0:
            return 0.7
        case ...1.25:
            return 0.45
        default:
            return 0.2
        }
    }

    static func scoreRating(_ rating: Double?) -> Double {
        guard let rating else { return 0.65 }
        return min(max(rating / 5.0, 0), 1)
    }

    static func scoreVibeMatch(notes: String?, preferences: [String]) -> Double {
        guard
            let notes,
            !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !preferences.isEmpty
        else {
            return 0.5
        }

        let lowercasedNotes = notes.lowercased()
        let matches = preferences.filter { lowercasedNotes.contains($0.lowercased()) }
        return min(1.0, Double(matches.count) / Double(preferences.count))
    }

    static func normalize(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}
