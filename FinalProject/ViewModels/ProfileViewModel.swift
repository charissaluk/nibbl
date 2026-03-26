//
//  ProfileViewModel.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//
import Foundation
import SwiftData
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    struct ProfileStats: Hashable {
        let savedCount: Int
        let visitedCount: Int
    }

    @Published private(set) var stats = ProfileStats(savedCount: 0, visitedCount: 0)
    @Published private(set) var savedRestaurants: [Restaurant] = []
    @Published private(set) var visitedRestaurants: [Restaurant] = []

    func reload(from restaurants: [Restaurant]) {
        let saved = restaurants
            .filter { $0.isSaved }
            .sorted { $0.createdAt > $1.createdAt }

        let visited = restaurants
            .filter { $0.isVisited }
            .sorted { $0.createdAt > $1.createdAt }

        savedRestaurants = saved
        visitedRestaurants = visited
        stats = ProfileStats(
            savedCount: saved.count,
            visitedCount: visited.count
        )
    }
}
