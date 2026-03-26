//
//  SearchMapViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/22/26.
//
import Foundation
import MapKit
import CoreLocation
import Combine

final class SearchMapViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var region: MKCoordinateRegion
    @Published var results: [Restaurant] = []
    @Published var filters: FilterSettings = .default
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isShowingFilters: Bool = false
    @Published var userLocation: CLLocation?

    private let searchService: RestaurantSearchServicing

    init(searchService: RestaurantSearchServicing = RestaurantSearchService()) {
        self.searchService = searchService
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.3299, longitude: -76.6205),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    }

    var visibleResults: [Restaurant] {
        results.filter { restaurant in
            matchesFilters(restaurant)
        }
    }

    func searchCurrentQuery() async {
        await runSearch(using: effectiveQuery())
    }

    func searchThisArea() async {
        await runSearch(using: effectiveQuery())
    }

    func resetFilters() {
        filters = .default
    }

    private func effectiveQuery() -> String {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedSearch.isEmpty {
            if let firstCuisine = filters.cuisines.first, !trimmedSearch.localizedCaseInsensitiveContains(firstCuisine) {
                return "\(firstCuisine) \(trimmedSearch)"
            }
            return trimmedSearch
        }

        if let firstCuisine = filters.cuisines.first {
            return "\(firstCuisine) restaurants"
        }

        return "Restaurants"
    }

    private func runSearch(using query: String) async {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }

        do {
            let fetched = try await searchService.searchRestaurants(
                query: query,
                region: region,
                userLocation: userLocation
            )

            await MainActor.run {
                self.results = fetched
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Could not load restaurants for this area."
                self.results = []
                self.isLoading = false
            }
        }
    }

    private func matchesFilters(_ restaurant: Restaurant) -> Bool {
        let cuisineMatches: Bool = {
            guard !filters.cuisines.isEmpty else { return true }
            return filters.cuisines.contains {
                $0.caseInsensitiveCompare(restaurant.cuisine) == .orderedSame
            }
        }()

        let priceMatches = PriceTierHelper.isWithinRange(
            restaurant.priceTier,
            min: filters.minPrice,
            max: filters.maxPrice
        )

        let distanceMatches: Bool = {
            guard let distance = restaurant.distanceFromUser else { return true }
            return distance <= filters.maxDistanceMiles
        }()

        let ratingMatches: Bool = {
            guard let rating = restaurant.rating else { return true }
            return rating >= filters.minimumRating
        }()

        return cuisineMatches && priceMatches && distanceMatches && ratingMatches
    }
}
