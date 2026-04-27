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
    var restaurantName: String
    var restaurantCuisine: String
    var restaurantAddress: String
    var restaurantLatitude: Double
    var restaurantLongitude: Double
    var mode: String
    var reservationDate: Date
    var status: String
    var acceptsReservations: Bool
    var bookingProvider: String?
    var bookingURLString: String?
    var messages: [String]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        restaurantID: UUID,
        planningSessionID: UUID,
        restaurantName: String = "Restaurant",
        restaurantCuisine: String = "Restaurant",
        restaurantAddress: String = "Address unavailable",
        restaurantLatitude: Double = 0,
        restaurantLongitude: Double = 0,
        mode: String = "individual",
        reservationDate: Date,
        status: String = "draft",
        acceptsReservations: Bool = true,
        bookingProvider: String? = nil,
        bookingURLString: String? = nil,
        messages: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.restaurantID = restaurantID
        self.planningSessionID = planningSessionID
        self.restaurantName = restaurantName
        self.restaurantCuisine = restaurantCuisine
        self.restaurantAddress = restaurantAddress
        self.restaurantLatitude = restaurantLatitude
        self.restaurantLongitude = restaurantLongitude
        self.mode = mode
        self.reservationDate = reservationDate
        self.status = status
        self.acceptsReservations = acceptsReservations
        self.bookingProvider = bookingProvider
        self.bookingURLString = bookingURLString
        self.messages = messages
        self.createdAt = createdAt
    }

    var effectiveStatus: String {
        if reservationDate < Date(), status != "cancelled" {
            return "completed"
        }
        return status
    }
}
