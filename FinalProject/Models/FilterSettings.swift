//
//  FilterSettings.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation

struct FilterSettings: Hashable, Codable {
    var cuisines: [String]
    var minPrice: String
    var maxPrice: String
    var maxDistanceMiles: Double
    var minimumRating: Double

    init(
        cuisines: [String] = [],
        minPrice: String = "$",
        maxPrice: String = "$$$$",
        maxDistanceMiles: Double = 10,
        minimumRating: Double = 0
    ) {
        self.cuisines = cuisines
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.maxDistanceMiles = maxDistanceMiles
        self.minimumRating = minimumRating
    }

    static let `default` = FilterSettings()
}
