//
//  PriceTierHelper.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation

enum PriceTierHelper {
    static let orderedTiers: [String] = ["$", "$$", "$$$", "$$$$"]

    static func rank(for tier: String) -> Int? {
        orderedTiers.firstIndex(of: tier)
    }

    static func isWithinRange(_ tier: String, min: String, max: String) -> Bool {
        guard
            let value = rank(for: tier),
            let minValue = rank(for: min),
            let maxValue = rank(for: max)
        else {
            return false
        }

        return value >= minValue && value <= maxValue
    }

    static func normalizedMatchScore(_ tier: String, min minTier: String, max maxTier: String) -> Double {
        guard
            let value = rank(for: tier),
            let minValue = rank(for: minTier),
            let maxValue = rank(for: maxTier)
        else {
            return 0
        }

        if value >= minValue && value <= maxValue {
            return 1
        }

        let distanceToRange = Swift.min(abs(value - minValue), abs(value - maxValue))
        return Swift.max(0, 1.0 - (Double(distanceToRange) * 0.4))
    }
}
