//
//  DistanceFormatter.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation

enum DistanceFormatter {
    static func milesString(from miles: Double?) -> String {
        guard let miles else { return "—" }

        if miles < 0.1 {
            return "< 0.1 mi"
        } else if miles < 10 {
            return String(format: "%.1f mi", miles)
        } else {
            return String(format: "%.0f mi", miles)
        }
    }
}
