//
//  PlanSetupViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//
import Foundation
import Combine
import SwiftData

final class PlanSetupViewModel: ObservableObject {
    enum SessionMode: String, CaseIterable, Identifiable {
        case individual = "Individual"
        case group = "Group"

        var id: String { rawValue }

        var persistenceValue: String {
            rawValue.lowercased()
        }
    }

    enum TransportMode: String, CaseIterable, Identifiable {
        case walking = "Walking"
        case transit = "Transit"
        case driving = "Driving"

        var id: String { rawValue }

        var persistenceValue: String {
            rawValue.lowercased()
        }

        var recommendedCap: Double {
            switch self {
            case .walking: return 1
            case .transit: return 2
            case .driving: return 10
            }
        }
    }

    @Published var selectedMode: SessionMode = .individual
    @Published var selectedCuisines: Set<String> = []
    @Published var minPrice: String = "$"
    @Published var maxPrice: String = "$$$"
    @Published var selectedTransportMode: TransportMode = .driving
    enum RestaurantSource: String, CaseIterable, Identifiable {
        case savedOnly = "Saved Only"
        case widerSelection = "Wider Selection"

        var id: String { rawValue }

        var helperText: String {
            switch self {
            case .savedOnly:
                return "Swipe through restaurants you’ve already saved."
            case .widerSelection:
                return "Include saved restaurants plus starter map recommendations for a bigger pool."
            }
        }
    }
    @Published var maxDistanceMiles: Double = 5
    @Published var selectedFriendIDs: Set<String> = []
    @Published var selectedRestaurantSource: RestaurantSource = .widerSelection

    @Published private(set) var availableFriends: [MockUserProfile] = []
    @Published private(set) var lastCreatedSession: PlanningSession?
    @Published var successMessage: String?
    @Published var errorMessage: String?

    let availableCuisines: [String] = [
        "Japanese", "Korean", "Chinese", "Thai", "Vietnamese",
        "Pizza", "Tacos", "Fast Casual", "Halal",
        "French", "Italian", "Steakhouse", "Wine Bar", "Omakase",
        "American", "Mediterranean", "Indian", "Mexican", "Cafe"
    ]

    private let mockUserService: MockUserServicing

    init(mockUserService: MockUserServicing = MockUserService()) {
        self.mockUserService = mockUserService
        self.availableFriends = mockUserService.fetchAllUsers()
        self.maxDistanceMiles = selectedTransportMode.recommendedCap
    }

    var isGroupMode: Bool {
        selectedMode == .group
    }

    var canStartSession: Bool {
        if isGroupMode {
            return !selectedFriendIDs.isEmpty
        }
        return true
    }

    func toggleCuisine(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }

    func toggleFriend(_ friendID: String) {
        if selectedFriendIDs.contains(friendID) {
            selectedFriendIDs.remove(friendID)
        } else {
            selectedFriendIDs.insert(friendID)
        }
    }

    func updateDistanceForTransportIfNeeded() {
        let cap = selectedTransportMode.recommendedCap
        if maxDistanceMiles > cap {
            maxDistanceMiles = cap
        }
        if maxDistanceMiles <= 0 {
            maxDistanceMiles = cap
        }
    }

    func resetMessages() {
        successMessage = nil
        errorMessage = nil
    }

    func startSession(context: ModelContext) {
        resetMessages()

        guard PriceTierHelper.isWithinRange(maxPrice, min: minPrice, max: "$$$$") else {
            errorMessage = "Please choose a valid max price."
            return
        }

        guard
            let minRank = PriceTierHelper.rank(for: minPrice),
            let maxRank = PriceTierHelper.rank(for: maxPrice),
            minRank <= maxRank
        else {
            errorMessage = "Minimum price must be less than or equal to maximum price."
            return
        }

        if isGroupMode && selectedFriendIDs.isEmpty {
            errorMessage = "Select at least one friend for a group session."
            return
        }

        let session = PlanningSession(
            mode: selectedMode.persistenceValue,
            selectedCuisineFilters: Array(selectedCuisines).sorted(),
            minPriceTier: minPrice,
            maxPriceTier: maxPrice,
            transportMode: selectedTransportMode.persistenceValue,
            maxDistanceMiles: maxDistanceMiles,
            selectedFriendIDs: Array(selectedFriendIDs).sorted(),
            candidateRestaurantIDs: [],
            finalRestaurantID: nil
        )

        context.insert(session)

        do {
            try context.save()
            lastCreatedSession = session
            successMessage = buildSuccessMessage(from: session)
        } catch {
            errorMessage = "Could not save the planning session. Please try again."
        }
    }

    private func buildSuccessMessage(from session: PlanningSession) -> String {
        if session.mode == "group" {
            return "Group session created for \(session.selectedFriendIDs.count) friend(s). Swipe recommendations will come next."
        } else {
            return "Individual session created. Swipe recommendations will come next."
        }
    }
}
