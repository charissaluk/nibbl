//
//  MockUserProfile.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/15/26.
//


import Foundation

struct MockUserProfile: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let preferredCuisines: [String]
    let minPrice: String
    let maxPrice: String
    let distanceToleranceMiles: Double
    let vibePreferences: [String]
    let savedRestaurantBoost: Double

    static let mei = MockUserProfile(
        id: "mei",
        name: "Mei",
        preferredCuisines: ["Japanese", "Korean", "Chinese", "Thai", "Vietnamese"],
        minPrice: "$$",
        maxPrice: "$$$",
        distanceToleranceMiles: 5,
        vibePreferences: ["Trendy", "Casual", "Modern", "Cute"],
        savedRestaurantBoost: 0.08
    )

    static let jordan = MockUserProfile(
        id: "jordan",
        name: "Jordan",
        preferredCuisines: ["Pizza", "Tacos", "Fast Casual", "Cheap Ramen", "Halal"],
        minPrice: "$",
        maxPrice: "$$",
        distanceToleranceMiles: 8,
        vibePreferences: ["Quick", "Casual", "Affordable", "Late Night"],
        savedRestaurantBoost: 0.04
    )

    static let eliza = MockUserProfile(
        id: "eliza",
        name: "Eliza",
        preferredCuisines: ["French", "Italian", "Steakhouse", "Wine Bar", "Omakase"],
        minPrice: "$$$",
        maxPrice: "$$$$",
        distanceToleranceMiles: 6,
        vibePreferences: ["Date Night", "Cocktails", "Elegant", "Upscale"],
        savedRestaurantBoost: 0.06
    )

    static let leo = MockUserProfile(
        id: "leo",
        name: "Leo",
        preferredCuisines: [
            "Japanese", "Korean", "Chinese", "Thai", "Vietnamese",
            "Pizza", "Tacos", "Fast Casual", "Halal",
            "French", "Italian", "Steakhouse", "Wine Bar", "Omakase",
            "American", "Mediterranean", "Indian", "Mexican"
        ],
        minPrice: "$",
        maxPrice: "$$$",
        distanceToleranceMiles: 10,
        vibePreferences: ["Adventurous", "Lively", "Hidden Gem", "Local Favorite"],
        savedRestaurantBoost: 0.05
    )

    static let allMockUsers: [MockUserProfile] = [.mei, .jordan, .eliza, .leo]
}
