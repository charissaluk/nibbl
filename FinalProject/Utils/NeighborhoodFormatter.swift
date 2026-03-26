//
//  NeighborhoodFormatter.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//

import Foundation

enum NeighborhoodFormatter {
    static func displayName(neighborhood: String?) -> String {
        guard let neighborhood,
              !neighborhood.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return "Nearby"
        }

        return neighborhood
    }
}
