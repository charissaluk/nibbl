//
//  ContentVIew.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/5/26.
//
import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {

            Text("Home")
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }

            Text("Plan")
                .tabItem {
                    Label("Plan", systemImage: "sparkles")
                }

            Text("Map")
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            Text("Lists")
                .tabItem {
                    Label("Lists", systemImage: "list.bullet")
                }
        }
    }
}
