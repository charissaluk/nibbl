//
//  RootTabView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//
import SwiftUI

@MainActor
struct RootTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppState.Tab.home)

            NavigationStack {
                SearchMapView()
            }
            .tabItem {
                Label("Search", systemImage: "map.fill")
            }
            .tag(AppState.Tab.search)

            NavigationStack {
                PlanSetupView()
            }
            .tabItem {
                Label("Plan", systemImage: "slider.horizontal.3")
            }
            .tag(AppState.Tab.plan)

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle.fill")
            }
            .tag(AppState.Tab.profile)

            NavigationStack {
                ListsView()
            }
            .tabItem {
                Label("Lists", systemImage: "bookmark.fill")
            }
            .tag(AppState.Tab.lists)
        }
        .tint(.primary)
    }
}
