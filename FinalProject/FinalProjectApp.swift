//
//  FinalProjectApp.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/5/26.
//

import SwiftUI
import SwiftData

@main
struct FinalProjectApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Restaurant.self
        ])
    }
}
