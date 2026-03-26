//
//  RestaurantList.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/5/26.
//


import Foundation
import SwiftData

@Model
final class RestaurantList {
    var id: UUID
    var name: String
    var createdAt: Date

    @Relationship
    var restaurants: [Restaurant]

    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        restaurants: [Restaurant] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.restaurants = restaurants
    }
}
