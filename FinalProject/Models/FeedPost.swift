//
//  FeedPost.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation

struct FeedPost: Identifiable, Hashable, Codable {
    let id: UUID
    let userID: String
    let restaurantName: String
    let restaurantCuisine: String
    let rating: Double
    let timestamp: Date
    let caption: String
    let imageName: String?

    init(
        id: UUID = UUID(),
        userID: String,
        restaurantName: String,
        restaurantCuisine: String,
        rating: Double,
        timestamp: Date,
        caption: String,
        imageName: String? = nil
    ) {
        self.id = id
        self.userID = userID
        self.restaurantName = restaurantName
        self.restaurantCuisine = restaurantCuisine
        self.rating = rating
        self.timestamp = timestamp
        self.caption = caption
        self.imageName = imageName
    }
}
