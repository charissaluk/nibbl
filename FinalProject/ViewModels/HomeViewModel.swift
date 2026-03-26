//
//  HomeViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//
import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    struct FeedItem: Identifiable, Hashable {
        let id: UUID
        let friendName: String
        let restaurantName: String
        let restaurantCuisine: String
        let rating: Double
        let timestamp: Date
        let caption: String
        let imageName: String?

        var asRestaurant: Restaurant {
            Restaurant(
                name: restaurantName,
                cuisine: restaurantCuisine,
                priceTier: "$$",
                latitude: 39.3299,
                longitude: -76.6205,
                address: "Address unavailable",
                rating: rating,
                distanceFromUser: nil,
                neighborhood: "Nearby",
                isSaved: false,
                isVisited: false,
                notes: caption
            )
        }
    }

    @Published private(set) var feedItems: [FeedItem] = []

    private let feedService: MockFeedServicing
    private let userService: MockUserServicing

    init(
        feedService: MockFeedServicing = MockFeedService(),
        userService: MockUserServicing = MockUserService()
    ) {
        self.feedService = feedService
        self.userService = userService
        loadFeed()
    }

    func loadFeed() {
        let usersByID = Dictionary(
            uniqueKeysWithValues: userService.fetchAllUsers().map { ($0.id, $0.name) }
        )

        feedItems = feedService.fetchFeedPosts().map { post in
            FeedItem(
                id: post.id,
                friendName: usersByID[post.userID] ?? "Friend",
                restaurantName: post.restaurantName,
                restaurantCuisine: post.restaurantCuisine,
                rating: post.rating,
                timestamp: post.timestamp,
                caption: post.caption,
                imageName: post.imageName
            )
        }
    }
}
