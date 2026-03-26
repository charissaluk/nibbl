//
//  FinalProjectApp.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//
import SwiftUI
import SwiftData
import Combine

@main
struct FinalProjectApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
        }
        .modelContainer(for: [
            Restaurant.self,
            RestaurantList.self,
            PlanningSession.self,
            SwipeDecision.self,
            Reservation.self
        ])
    }
}
