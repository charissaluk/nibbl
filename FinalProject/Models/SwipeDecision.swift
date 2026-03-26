//
//  SwipeDecision.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation
import SwiftData

@Model
final class SwipeDecision {
    var id: UUID
    var sessionID: UUID
    var restaurantID: UUID
    var decision: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        sessionID: UUID,
        restaurantID: UUID,
        decision: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sessionID = sessionID
        self.restaurantID = restaurantID
        self.decision = decision
        self.createdAt = createdAt
    }
}
