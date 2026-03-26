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

            let placemark = item.placemark
            let coordinate = placemark.coordinate

            let addressParts = [
                placemark.subThoroughfare,
                placemark.thoroughfare,
                placemark.locality,
                placemark.administrativeArea
            ]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

            let address = addressParts.isEmpty
                ? "Address unavailable"
                : addressParts.joined(separator: ", ")

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
                neighborhood: placemark.subLocality ?? placemark.locality,
                isSaved: false,
                isVisited: false,
                notes: nil
            )
        }
    }

    private func inferredCuisine(from item: MKMapItem) -> String {
        let sourceText = [
            item.name,
            item.placemark.title
        ]
        .compactMap { $0?.lowercased() }
        .joined(separator: " ")

        let mappings: [(keywords: [String], cuisine: String)] = [
            (["sushi", "ramen", "izakaya", "yakitori"], "Japanese"),
            (["thai", "pad thai", "bangkok"], "Thai"),
            (["pizza", "pizzeria"], "Pizza"),
            (["taco", "taqueria", "burrito"], "Tacos"),
            (["halal", "shawarma", "gyro"], "Halal"),
            (["steak", "steakhouse"], "Steakhouse"),
            (["wine", "wine bar"], "Wine Bar"),
            (["italian", "pasta", "trattoria"], "Italian"),
            (["french", "bistro", "brasserie"], "French"),
            (["indian", "curry", "tandoor"], "Indian"),
            (["korean", "bbq", "bulgogi"], "Korean"),
            (["chinese", "dumpling", "dim sum"], "Chinese"),
            (["viet", "pho", "banh mi"], "Vietnamese"),
            (["burger", "american", "grill"], "American"),
            (["mediterranean", "falafel", "mezze"], "Mediterranean"),
            (["cafe", "coffee"], "Cafe"),
            (["omakase"], "Omakase")
        ]

        for mapping in mappings {
            if mapping.keywords.contains(where: { sourceText.contains($0) }) {
                return mapping.cuisine
            }
        }

        return "Restaurant"
    }

    private func inferredPriceTier(from item: MKMapItem) -> String {
        let sourceText = [
            item.name,
            item.placemark.title
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
