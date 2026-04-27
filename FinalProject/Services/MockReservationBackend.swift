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

        let encodedName = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "restaurant"

        if providerName(for: restaurant) == "Resy" {
            return "https://resy.com/search?query=\(encodedName)"
        } else {
            return "https://www.opentable.com/s?term=\(encodedName)"
        }
    }

    static func defaultMessages(for mode: String) -> [String] {
        if mode == "group" {
            return [
                "Me: I’m free the 24th and 25th after 6 PM.",
                "Mei: I can also do the 25th!",
                "Jordan: 25th works for me after 7."
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
