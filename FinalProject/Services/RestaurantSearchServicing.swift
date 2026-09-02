//
//  RestaurantSearchServicing.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//
import CoreLocation
import Foundation
import MapKit

protocol RestaurantSearchServicing {
    @MainActor
    func searchRestaurants(
        query: String,
        region: MKCoordinateRegion,
        userLocation: CLLocation?
    ) async throws -> [Restaurant]
}

struct RestaurantSearchService: RestaurantSearchServicing {
    @MainActor
    func searchRestaurants(
        query: String,
        region: MKCoordinateRegion,
        userLocation: CLLocation?
    ) async throws -> [Restaurant] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query.isEmpty ? "Restaurants" : query
        request.resultTypes = .pointOfInterest
        request.region = region

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        return response.mapItems.compactMap { item in
            guard let name = item.name else { return nil }

            let address = item.address?.fullAddress ?? "Address unavailable"
            let coordinate = item.location.coordinate

            let cuisine = inferredCuisine(from: item)
            let priceTier = inferredPriceTier(from: item)

            return Restaurant(
                name: name,
                cuisine: cuisine,
                priceTier: priceTier,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                address: address,
                rating: nil,
                distanceFromUser: {
                    guard let userLocation else { return nil }

                    let restaurantLocation = CLLocation(
                        latitude: coordinate.latitude,
                        longitude: coordinate.longitude
                    )

                    let meters = userLocation.distance(from: restaurantLocation)
                    return meters / 1609.34
                }(),
                neighborhood: item.address?.shortAddress,
                isSaved: false,
                isVisited: false,
                notes: nil
            )
        }
    }

    private func inferredCuisine(from item: MKMapItem) -> String {
        let sourceText = [
            item.name,
            item.address?.fullAddress,
            item.address?.shortAddress
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")

        var cuisines: [String] = []

        func add(_ cuisine: String) {
            if !cuisines.contains(cuisine) {
                cuisines.append(cuisine)
            }
        }

        let mappings: [(keywords: [String], cuisine: String)] = [
            (["sushi", "ramen", "izakaya", "yakitori", "japanese"], "Japanese"),
            (["thai", "pad thai", "bangkok"], "Thai"),
            (["pizza", "pizzeria"], "Pizza"),
            (["taco", "taqueria", "burrito", "mexican"], "Mexican"),
            (["halal", "shawarma", "gyro"], "Halal"),
            (["steak", "steakhouse"], "Steakhouse"),
            (["wine", "wine bar"], "Wine Bar"),
            (["italian", "pasta", "trattoria"], "Italian"),
            (["french", "bistro", "brasserie"], "French"),
            (["indian", "curry", "tandoor"], "Indian"),
            (["korean", "bbq", "bulgogi"], "Korean"),
            (["chinese", "dumpling", "dim sum"], "Chinese"),
            (["viet", "pho", "banh mi"], "Vietnamese"),
            (["burger", "american", "grill", "bar"], "American"),
            (["mediterranean", "falafel", "mezze"], "Mediterranean"),
            (["cafe", "coffee", "espresso", "bakery"], "Cafe"),
            (["omakase"], "Omakase")
        ]

        for mapping in mappings {
            if mapping.keywords.contains(where: { sourceText.contains($0) }) {
                add(mapping.cuisine)
            }
        }

        if item.pointOfInterestCategory == .cafe {
            add("Cafe")
        } else if item.pointOfInterestCategory == .bakery {
            add("Cafe")
        } else if item.pointOfInterestCategory == .brewery {
            add("American")
        } else if item.pointOfInterestCategory == .winery {
            add("Wine Bar")
        } else if item.pointOfInterestCategory == .restaurant && cuisines.isEmpty {
            add("Restaurant")
        }

        return cuisines.isEmpty ? "Restaurant" : cuisines.prefix(2).joined(separator: ", ")
    }

    private func inferredPriceTier(from item: MKMapItem) -> String {
        let sourceText = [
            item.name,
            item.address?.fullAddress,
            item.address?.shortAddress
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")

        if sourceText.contains("omakase") || sourceText.contains("steakhouse") {
            return "$$$$"
        } else if sourceText.contains("wine") || sourceText.contains("french") {
            return "$$$"
        } else {
            return "$$"
        }
    }
}
