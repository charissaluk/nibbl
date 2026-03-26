//
//  Reservation.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation
import SwiftData

@Model
final class Reservation {
    var id: UUID
    var restaurantID: UUID
    var planningSessionID: UUID
    var reservationDate: Date
    var status: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        restaurantID: UUID,
        planningSessionID: UUID,
        reservationDate: Date,
        status: String = "draft",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.restaurantID = restaurantID
        self.planningSessionID = planningSessionID
        self.reservationDate = reservationDate
        self.status = status
        self.createdAt = createdAt
    }
}
