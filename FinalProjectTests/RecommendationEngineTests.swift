import XCTest
@testable import FinalProject

@MainActor
final class RecommendationEngineTests: XCTestCase {
    func testCuisineMatchingIsCaseInsensitiveAndFallsBackWithoutPreferences() {
        XCTAssertEqual(
            RecommendationScoring.scoreCuisineMatch(
                restaurantCuisine: "Japanese",
                preferredCuisines: ["japanese"]
            ),
            1.0,
            accuracy: 0.001
        )
        XCTAssertEqual(
            RecommendationScoring.scoreCuisineMatch(
                restaurantCuisine: "Japanese",
                preferredCuisines: ["Italian"]
            ),
            0.15,
            accuracy: 0.001
        )
        XCTAssertEqual(
            RecommendationScoring.scoreCuisineMatch(
                restaurantCuisine: "Japanese",
                preferredCuisines: []
            ),
            0.75,
            accuracy: 0.001
        )
    }

    func testPriceTierRankingAndValidation() {
        XCTAssertTrue(PriceTierHelper.isWithinRange("$$", min: "$", max: "$$$"))
        XCTAssertFalse(PriceTierHelper.isWithinRange("$$$$", min: "$", max: "$$"))
        XCTAssertFalse(PriceTierHelper.isWithinRange("unknown", min: "$", max: "$$$"))

        XCTAssertEqual(PriceTierHelper.normalizedMatchScore("$$", min: "$", max: "$$$"), 1.0, accuracy: 0.001)
        XCTAssertEqual(PriceTierHelper.normalizedMatchScore("$$$$", min: "$", max: "$$"), 0.2, accuracy: 0.001)
        XCTAssertEqual(PriceTierHelper.normalizedMatchScore("unknown", min: "$", max: "$$"), 0.0, accuracy: 0.001)
    }

    func testDistanceScoringAndHardDistanceCaps() {
        XCTAssertEqual(RecommendationScoring.hardDistanceCap(for: "walking"), 1.0)
        XCTAssertEqual(RecommendationScoring.hardDistanceCap(for: "transit"), 2.0)
        XCTAssertEqual(RecommendationScoring.hardDistanceCap(for: "driving"), 10.0)

        XCTAssertEqual(RecommendationScoring.scoreDistance(distance: nil, idealMax: 5), 0.75)
        XCTAssertEqual(RecommendationScoring.scoreDistance(distance: 1.0, idealMax: 5), 1.0)
        XCTAssertEqual(RecommendationScoring.scoreDistance(distance: 6.5, idealMax: 5), 0.2)

        let filters = FilterSettings(maxDistanceMiles: 10)
        XCTAssertTrue(
            RecommendationScoring.passesHardFilters(
                restaurant: restaurant(name: "Near", distance: 0.8),
                filters: filters,
                hardDistanceCap: 1.0
            )
        )
        XCTAssertFalse(
            RecommendationScoring.passesHardFilters(
                restaurant: restaurant(name: "Too Far", distance: 1.2),
                filters: filters,
                hardDistanceCap: 1.0
            )
        )
    }

    func testSavedRestaurantBoostAffectsRecommendationOrdering() {
        let engine = RecommendationEngine()
        let filters = FilterSettings(cuisines: ["Japanese"], minPrice: "$$", maxPrice: "$$", maxDistanceMiles: 3)
        let unsaved = restaurant(name: "A Unsaved", cuisine: "Japanese", priceTier: "$$", distance: 0.5)
        let saved = restaurant(name: "Z Saved", cuisine: "Japanese", priceTier: "$$", distance: 0.5, isSaved: true)

        let ranked = engine.rankRestaurants(
            candidates: [unsaved, saved],
            currentUserFilters: filters,
            selectedFriends: [],
            transportMode: "driving"
        )

        XCTAssertEqual(ranked.first?.restaurant.name, "Z Saved")
        XCTAssertGreaterThan(ranked[0].score, ranked[1].score)
    }

    func testFriendCompatibilityIsCalculatedAndBounded() throws {
        let engine = RecommendationEngine()
        let filters = FilterSettings(minPrice: "$", maxPrice: "$$$$", maxDistanceMiles: 10)

        let ranked = engine.rankRestaurants(
            candidates: [restaurant(name: "Sushi Spot", cuisine: "Japanese", priceTier: "$$", distance: 1)],
            currentUserFilters: filters,
            selectedFriends: [.mei, .eliza],
            transportMode: "driving"
        )

        let result = try XCTUnwrap(ranked.first)
        XCTAssertEqual(Set(result.friendCompatibility.keys), ["mei", "eliza"])
        XCTAssertTrue((0...1).contains(result.score))
        XCTAssertTrue(result.friendCompatibility.values.allSatisfy { (0...1).contains($0) })
        XCTAssertGreaterThan(result.friendCompatibility["mei"] ?? 0, result.friendCompatibility["eliza"] ?? 1)
    }

    func testRecommendationOrderingFallsBackToNameWhenScoresTie() {
        let engine = RecommendationEngine()
        let filters = FilterSettings(minPrice: "$", maxPrice: "$$$$", maxDistanceMiles: 10)

        let ranked = engine.rankRestaurants(
            candidates: [
                restaurant(name: "Beta", cuisine: "Italian", priceTier: "$$", distance: 1),
                restaurant(name: "Alpha", cuisine: "Italian", priceTier: "$$", distance: 1)
            ],
            currentUserFilters: filters,
            selectedFriends: [],
            transportMode: "driving"
        )

        XCTAssertEqual(ranked.map { $0.restaurant.name }, ["Alpha", "Beta"])
    }

    func testDeduplicationKeepsFirstRestaurantForNameAndAddress() {
        let first = restaurant(name: "Cafe Nibbl", address: "1 Main Street")
        let duplicate = restaurant(name: " cafe nibbl ", address: "1 main street")
        let second = restaurant(name: "Dinner Nibbl", address: "2 Main Street")

        let deduped = RestaurantDeduplicator.deduplicate([first, duplicate, second])

        XCTAssertEqual(deduped.map { $0.name }, ["Cafe Nibbl", "Dinner Nibbl"])
    }

    func testAppleMapsURLUsesHttpsAndRestaurantQuery() throws {
        let url = try XCTUnwrap(
            AppleMapsURLBuilder.url(
                for: restaurant(
                    name: "Nibbl & Co",
                    latitude: 39.3299,
                    longitude: -76.6205
                )
            )
        )
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.scheme, "https")
        XCTAssertEqual(components.host, "maps.apple.com")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "ll" })?.value, "39.3299,-76.6205")
        XCTAssertEqual(components.queryItems?.first(where: { $0.name == "q" })?.value, "Nibbl & Co")
    }

    func testScoresRemainBounded() {
        XCTAssertEqual(RecommendationScoring.normalize(-0.2), 0.0)
        XCTAssertEqual(RecommendationScoring.normalize(1.4), 1.0)
        XCTAssertEqual(RecommendationScoring.scoreRating(6), 1.0)
        XCTAssertEqual(RecommendationScoring.scoreRating(-1), 0.0)
    }

    private func restaurant(
        name: String,
        cuisine: String = "Japanese",
        priceTier: String = "$$",
        address: String = "1 Main Street",
        rating: Double? = 4.5,
        distance: Double? = 1,
        latitude: Double = 39.0,
        longitude: Double = -76.0,
        isSaved: Bool = false,
        notes: String? = nil
    ) -> Restaurant {
        Restaurant(
            name: name,
            cuisine: cuisine,
            priceTier: priceTier,
            latitude: latitude,
            longitude: longitude,
            address: address,
            rating: rating,
            distanceFromUser: distance,
            isSaved: isSaved,
            notes: notes
        )
    }
}
