//
//  Restaurant.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/5/26.
//

import Foundation
import SwiftData

@Model
final class Restaurant {
    var id: UUID
    var name: String
    var cuisine: String
    var priceTier: String
    var latitude: Double
    var longitude: Double
    var address: String
    var rating: Double?
    var distanceFromUser: Double?
    var neighborhood: String?
    var isSaved: Bool
    var isVisited: Bool
    var notes: String?
    var createdAt: Date

    @Relationship(inverse: \RestaurantList.restaurants)
    var lists: [RestaurantList]

    init(
        id: UUID = UUID(),
        name: String,
        cuisine: String,
        priceTier: String,
        latitude: Double,
        longitude: Double,
        address: String,
        rating: Double? = nil,
        distanceFromUser: Double? = nil,
        neighborhood: String? = nil,
        isSaved: Bool = false,
        isVisited: Bool = false,
        notes: String? = nil,
        createdAt: Date = Date(),
        lists: [RestaurantList] = []
    ) {
        self.id = id
        self.name = name
        self.cuisine = cuisine
        self.priceTier = priceTier
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.rating = rating
        self.distanceFromUser = distanceFromUser
        self.neighborhood = neighborhood
        self.isSaved = isSaved
        self.isVisited = isVisited
        self.notes = notes
        self.createdAt = createdAt
        self.lists = lists
    }
}
