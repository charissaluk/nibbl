//
//  FilterSheetView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/20/26.
//


import SwiftUI

struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var localFilters: FilterSettings

    let availableCuisines: [String]
    let onApply: (FilterSettings) -> Void
    let onReset: () -> Void

    init(
        filters: FilterSettings,
        availableCuisines: [String],
        onApply: @escaping (FilterSettings) -> Void,
        onReset: @escaping () -> Void
    ) {
        _localFilters = State(initialValue: filters)
        self.availableCuisines = availableCuisines
        self.onApply = onApply
        self.onReset = onReset
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    cuisineSection
                    priceSection
                    distanceSection
                    ratingSection
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Reset") {
                        onReset()
                        localFilters = .default
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Apply") {
                        onApply(localFilters)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var cuisineSection: some View {
        filterCard(title: "Cuisine") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 10)], spacing: 10) {
                ForEach(availableCuisines, id: \.self) { cuisine in
                    Button {
                        toggleCuisine(cuisine)
                    } label: {
                        Text(cuisine)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(localFilters.cuisines.contains(cuisine) ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(
                                Capsule()
                                    .fill(localFilters.cuisines.contains(cuisine) ? Color.black : Color(.secondarySystemBackground))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var priceSection: some View {
        filterCard(title: "Price range") {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Min")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Picker("Minimum Price", selection: $localFilters.minPrice) {
                        ForEach(PriceTierHelper.orderedTiers, id: \.self) { tier in
                            Text(tier).tag(tier)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Max")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)

                    Picker("Maximum Price", selection: $localFilters.maxPrice) {
                        ForEach(PriceTierHelper.orderedTiers, id: \.self) { tier in
                            Text(tier).tag(tier)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    private var distanceSection: some View {
        filterCard(title: "Distance") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Max distance")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(DistanceFormatter.milesString(from: localFilters.maxDistanceMiles))
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $localFilters.maxDistanceMiles,
                    in: 1...15,
                    step: 0.5
                )
            }
        }
    }

    private var ratingSection: some View {
        filterCard(title: "Minimum rating") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Rating")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(localFilters.minimumRating == 0 ? "Any" : String(format: "%.1f+", localFilters.minimumRating))
                        .foregroundStyle(.secondary)
                }

                Slider(
                    value: $localFilters.minimumRating,
                    in: 0...5,
                    step: 0.5
                )
            }
        }
    }

    private func filterCard<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.headline)

            content()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private func toggleCuisine(_ cuisine: String) {
        if localFilters.cuisines.contains(cuisine) {
            localFilters.cuisines.removeAll { $0 == cuisine }
        } else {
            localFilters.cuisines.append(cuisine)
        }
    }
}
