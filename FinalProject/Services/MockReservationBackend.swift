//
//  MockReservationBackend.swift
//  FinalProject
//
//  Created by Charissa Luk on 4/26/26.
//

import Foundation

enum MockReservationBackend {
    static func acceptsReservations(for restaurant: Restaurant) -> Bool {
        let cuisine = restaurant.cuisine.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cuisine != "cafe" && cuisine != "wine bar"
    }

    static func providerName(for restaurant: Restaurant) -> String? {
        guard acceptsReservations(for: restaurant) else { return nil }

        let name = restaurant.name.lowercased()

        if name.contains("sushi") || name.contains("omakase") || name.contains("maison") {
            return "Resy"
        }

        return "OpenTable"
    }

    static func bookingURLString(for restaurant: Restaurant) -> String? {
        guard acceptsReservations(for: restaurant) else { return nil }

        let query = "\(restaurant.name) \(restaurant.address)"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "restaurant"

        return "https://www.google.com/maps/search/?api=1&query=\(encodedQuery)"
    }

    static func defaultMessages(for mode: String) -> [String] {
        if mode == "group" {
            return [
                "Me: I’m free the 8th and 9th after 6 PM.",
                "Mei: I can also do the 9th!",
                "Eliza: 9th also works for me but only after 7 PM."
            ]
        } else {
            return [
                "Me: Saving this as a draft while I decide on a time.",
                "Nibbl: Suggested time is 7:00 PM."
            ]
        }
    }

    static func confirm(_ reservation: Reservation) {
        guard reservation.acceptsReservations else {
            reservation.status = "draft"
            return
        }

        reservation.status = "confirmed"
    }

    static func cancel(_ reservation: Reservation) {
        reservation.status = "cancelled"
    }
}
