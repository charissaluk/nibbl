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

    var name: String
    var cuisine: String?
    var priceLevel: Int?
    var address: String?

    var latitude: Double?
    var longitude: Double?

    var rating: Int?
    var notes: String?

    var isVisited: Bool

    var createdAt: Date

    init(
        name: String,
        cuisine: String? = nil,
        priceLevel: Int? = nil,
        address: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        rating: Int? = nil,
        notes: String? = nil,
        isVisited: Bool = false
    ) {
        self.name = name
        self.cuisine = cuisine
        self.priceLevel = priceLevel
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
        self.notes = notes
        self.isVisited = isVisited
        self.createdAt = Date()
    }
}
