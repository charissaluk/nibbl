//
//  PlanningSession.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation
import SwiftData

@Model
final class PlanningSession {
    var id: UUID
    var mode: String
    var selectedCuisineFilters: [String]
    var minPriceTier: String
    var maxPriceTier: String
    var transportMode: String
    var maxDistanceMiles: Double
    var selectedFriendIDs: [String]
    var candidateRestaurantIDs: [UUID]
    var finalRestaurantID: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        mode: String,
        selectedCuisineFilters: [String] = [],
        minPriceTier: String,
        maxPriceTier: String,
        transportMode: String,
        maxDistanceMiles: Double,
        selectedFriendIDs: [String] = [],
        candidateRestaurantIDs: [UUID] = [],
        finalRestaurantID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.mode = mode
        self.selectedCuisineFilters = selectedCuisineFilters
        self.minPriceTier = minPriceTier
        self.maxPriceTier = maxPriceTier
        self.transportMode = transportMode
        self.maxDistanceMiles = maxDistanceMiles
        self.selectedFriendIDs = selectedFriendIDs
        self.candidateRestaurantIDs = candidateRestaurantIDs
        self.finalRestaurantID = finalRestaurantID
        self.createdAt = createdAt
    }
}
