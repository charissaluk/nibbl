//
//  MockFeedServicing.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation

protocol MockFeedServicing {
    func fetchFeedPosts() -> [FeedPost]
}

struct MockFeedService: MockFeedServicing {
    func fetchFeedPosts() -> [FeedPost] {
        [
            FeedPost(
                userID: "mei",
                restaurantName: "Sora Sushi",
                restaurantCuisine: "Japanese",
                rating: 4.7,
                timestamp: Date().addingTimeInterval(-60 * 60 * 3),
                caption: "Perfect casual sushi spot for a weeknight dinner.",
                imageName: nil
            ),
            FeedPost(
                userID: "jordan",
                restaurantName: "Halal Bros Express",
                restaurantCuisine: "Halal",
                rating: 4.4,
                timestamp: Date().addingTimeInterval(-60 * 60 * 8),
                caption: "Cheap, fast, and actually so good.",
                imageName: nil
            ),
            FeedPost(
                userID: "eliza",
                restaurantName: "Maison Rouge",
                restaurantCuisine: "French",
                rating: 4.8,
                timestamp: Date().addingTimeInterval(-60 * 60 * 20),
                caption: "Would absolutely go back for cocktails and dessert.",
                imageName: nil
            ),
            FeedPost(
                userID: "leo",
                restaurantName: "Spice Route Kitchen",
                restaurantCuisine: "Indian",
                rating: 4.6,
                timestamp: Date().addingTimeInterval(-60 * 60 * 28),
                caption: "Unexpected menu, fun vibe, and worth the drive.",
                imageName: nil
            ),
            FeedPost(
                userID: "mei",
                restaurantName: "Bangkok Station",
                restaurantCuisine: "Thai",
                rating: 4.5,
                timestamp: Date().addingTimeInterval(-60 * 60 * 36),
                caption: "Great noodles, cute interior, easy group pick.",
                imageName: nil
            )
        ]
        .sorted { $0.timestamp > $1.timestamp }
    }
}
