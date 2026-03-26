//
//  AppState.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AppState: ObservableObject {
    enum Tab: Hashable {
        case home
        case search
        case plan
        case profile
        case lists
    }

    @Published var selectedTab: Tab = .home

    init(selectedTab: Tab = .home) {
        self.selectedTab = selectedTab
    }

    func switchToTab(_ tab: Tab) {
        selectedTab = tab
    }
}
