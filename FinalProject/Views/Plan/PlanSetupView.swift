//
//  PlanSetupView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//
import SwiftUI
import SwiftData

struct PlanSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var savedRestaurants: [Restaurant]

    @StateObject private var viewModel: PlanSetupViewModel
    @State private var shouldNavigateToSwipe = false

    init() {
        _viewModel = StateObject(wrappedValue: PlanSetupViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                introCard
                modeSection
                sourceSection

                if viewModel.isGroupMode {
                    FriendSelectionView(
                        friends: viewModel.availableFriends,
                        selectedFriendIDs: viewModel.selectedFriendIDs,
                        onToggle: { id in
                            viewModel.toggleFriend(id)
                        }
                    )
                }

                cuisineSection
                budgetSection
                transportSection
                actionSection
                statusSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plan")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $shouldNavigateToSwipe) {
            if let session = viewModel.lastCreatedSession {
                SwipeDeckView(
                    session: session,
                    candidateRestaurants: candidateRestaurants
                )
            }
        }
        .onChange(of: viewModel.selectedTransportMode) { _, _ in
            viewModel.updateDistanceForTransportIfNeeded()
        }
        .onChange(of: viewModel.lastCreatedSession?.id) { _, newValue in
            if newValue != nil {
                shouldNavigateToSwipe = true
            }
        }
    }

    private var candidateRestaurants: [Restaurant] {
        let baseRestaurants: [Restaurant]

        switch viewModel.selectedRestaurantSource {
        case .savedOnly:
            baseRestaurants = savedRestaurants

        case .widerSelection:
            baseRestaurants = savedRestaurants + mockFallbackRestaurants
        }

        let deduped = dedupedRestaurants(baseRestaurants)
        let filtered = prefilterCandidates(deduped)

        if viewModel.selectedRestaurantSource == .widerSelection {
            return filtered.isEmpty ? mockFallbackRestaurants : filtered
        } else {
            return filtered
        }
    }

    private func dedupedRestaurants(_ restaurants: [Restaurant]) -> [Restaurant] {
        var seen = Set<String>()
        var output: [Restaurant] = []

        for restaurant in restaurants {
            let key = "\(restaurant.name.lowercased())|\(restaurant.address.lowercased())"
            if !seen.contains(key) {
                seen.insert(key)
                output.append(restaurant)
            }
        }

        return output
    }

    private func prefilterCandidates(_ restaurants: [Restaurant]) -> [Restaurant] {
        restaurants.filter { restaurant in
            let cuisinePass: Bool = {
                guard !viewModel.selectedCuisines.isEmpty else { return true }
                return viewModel.selectedCuisines.contains {
                    $0.caseInsensitiveCompare(restaurant.cuisine) == .orderedSame
                }
            }()

            let pricePass = PriceTierHelper.isWithinRange(
                restaurant.priceTier,
                min: viewModel.minPrice,
                max: viewModel.maxPrice
            )

            let distancePass: Bool = {
                guard let distance = restaurant.distanceFromUser else { return true }
                return distance <= viewModel.maxDistanceMiles
            }()

            return cuisinePass && pricePass && distancePass
        }
    }

    private var mockFallbackRestaurants: [Restaurant] {
        [
            Restaurant(
                name: "Sora Sushi",
                cuisine: "Japanese",
                priceTier: "$$",
                latitude: 39.3300,
                longitude: -76.6210,
                address: "1201 N Charles St, Baltimore, MD",
                rating: 4.7,
                distanceFromUser: 1.2,
                neighborhood: "Mount Vernon",
                isSaved: false,
                isVisited: false,
                notes: "Trendy casual sushi spot"
            ),
            Restaurant(
                name: "Bangkok Station",
                cuisine: "Thai",
                priceTier: "$$",
                latitude: 39.3289,
                longitude: -76.6195,
                address: "915 N Calvert St, Baltimore, MD",
                rating: 4.5,
                distanceFromUser: 1.0,
                neighborhood: "Midtown",
                isSaved: false,
                isVisited: false,
                notes: "Cute interior and easy group pick"
            ),
            Restaurant(
                name: "Maison Rouge",
                cuisine: "French",
                priceTier: "$$$",
                latitude: 39.3314,
                longitude: -76.6179,
                address: "800 St Paul St, Baltimore, MD",
                rating: 4.8,
                distanceFromUser: 2.4,
                neighborhood: "Mount Vernon",
                isSaved: false,
                isVisited: false,
                notes: "Elegant date night cocktails"
            ),
            Restaurant(
                name: "Halal Bros Express",
                cuisine: "Halal",
                priceTier: "$",
                latitude: 39.3275,
                longitude: -76.6221,
                address: "401 E Biddle St, Baltimore, MD",
                rating: 4.4,
                distanceFromUser: 1.6,
                neighborhood: "Station North",
                isSaved: false,
                isVisited: false,
                notes: "Quick, cheap, and satisfying"
            ),
            Restaurant(
                name: "Piazza Uno",
                cuisine: "Italian",
                priceTier: "$$$",
                latitude: 39.3320,
                longitude: -76.6244,
                address: "1010 Cathedral St, Baltimore, MD",
                rating: 4.6,
                distanceFromUser: 2.1,
                neighborhood: "Cathedral Hill",
                isSaved: false,
                isVisited: false,
                notes: "Warm lighting and upscale pasta"
            ),
            Restaurant(
                name: "K-Town Table",
                cuisine: "Korean",
                priceTier: "$$",
                latitude: 39.3331,
                longitude: -76.6238,
                address: "700 Cathedral St, Baltimore, MD",
                rating: 4.5,
                distanceFromUser: 1.7,
                neighborhood: "Mount Vernon",
                isSaved: false,
                isVisited: false,
                notes: "Casual, lively, and good for sharing"
            )
        ]
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Choose For Me")
                .font(.system(size: 28, weight: .bold))

            Text("Set the vibe, budget, and distance. Then we’ll turn this into a restaurant plan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color.gray.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .foregroundStyle(.white)
    }

    private var modeSection: some View {
        planSectionCard(title: "Mode") {
            Picker("Mode", selection: $viewModel.selectedMode) {
                ForEach(PlanSetupViewModel.SessionMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(.black)
        }
    }
    
    private var sourceSection: some View {
        planSectionCard(title: "Restaurant Pool") {
            VStack(alignment: .leading, spacing: 10) {
                Picker("Restaurant Pool", selection: $viewModel.selectedRestaurantSource) {
                    ForEach(PlanSetupViewModel.RestaurantSource.allCases) { source in
                        Text(source.rawValue).tag(source)
                    }
                }
                .pickerStyle(.segmented)

                Text(viewModel.selectedRestaurantSource.helperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if viewModel.selectedRestaurantSource == .savedOnly && savedRestaurants.isEmpty {
                    Text("No saved restaurants yet. Choose Wider Selection to start with sample map recommendations.")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.orange)
                }
            }
        }
    }

    private var cuisineSection: some View {
        planSectionCard(title: "Cuisines") {
            Text("Pick cuisines now, or leave this open to discover more options.")
                .font(.caption)
                .foregroundStyle(.secondary)

            FlexibleTagWrap(
                items: viewModel.availableCuisines,
                selectedItems: viewModel.selectedCuisines,
                onTap: { cuisine in
                    viewModel.toggleCuisine(cuisine)
                }
            )
        }
    }

    private var budgetSection: some View {
        planSectionCard(title: "Budget") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Choose the lowest and highest price tier you want included.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Min")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        Picker("Minimum Price", selection: $viewModel.minPrice) {
                            ForEach(PriceTierHelper.orderedTiers, id: \.self) { tier in
                                Text(tier).tag(tier)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(.black)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Max")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)

                        Picker("Maximum Price", selection: $viewModel.maxPrice) {
                            ForEach(PriceTierHelper.orderedTiers, id: \.self) { tier in
                                Text(tier).tag(tier)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(.black)
                    }
                }
            }
        }
    }

    private var transportSection: some View {
        planSectionCard(title: "Distance") {
            VStack(alignment: .leading, spacing: 14) {
                Picker("Transport", selection: $viewModel.selectedTransportMode) {
                    ForEach(PlanSetupViewModel.TransportMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            .tint(.black)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Max distance")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text(DistanceFormatter.milesString(from: viewModel.maxDistanceMiles))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Slider(
                        value: $viewModel.maxDistanceMiles,
                        in: 0.5...viewModel.selectedTransportMode.recommendedCap,
                        step: 0.5
                    )
                }

                Text(distanceHelperText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionSection: some View {
        Button {
            guard !candidateRestaurants.isEmpty else {
                viewModel.resetMessages()
                viewModel.errorMessage = "No restaurants match this setup. Try Wider Selection, loosen filters, or save more restaurants first."
                return
            }

            viewModel.startSession(context: modelContext)
        } label: {
            HStack {
                Text("Start Session")
                    .font(.headline)

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.title3)
            }
            .foregroundStyle(.white)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(viewModel.canStartSession && !candidateRestaurants.isEmpty ? Color.black : Color.gray)
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canStartSession || candidateRestaurants.isEmpty)
    }

    @ViewBuilder
    private var statusSection: some View {
        if let successMessage = viewModel.successMessage {
            StatusCard(
                title: "Session created",
                message: successMessage,
                systemImage: "checkmark.circle.fill",
                accentColor: .green
            )
        }

        if let errorMessage = viewModel.errorMessage {
            StatusCard(
                title: "Something went wrong",
                message: errorMessage,
                systemImage: "exclamationmark.triangle.fill",
                accentColor: .orange
            )
        }
    }

    private var distanceHelperText: String {
        switch viewModel.selectedTransportMode {
        case .walking:
            return "Walking plans keep options close, with a recommended hard cap around 1 mile."
        case .transit:
            return "Transit plans keep the walk manageable before or after the ride."
        case .driving:
            return "Driving plans allow the widest search area and the biggest candidate pool."
        }
    }

    private func planSectionCard<Content: View>(
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
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 6)
    }
}

private struct StatusCard: View {
    let title: String
    let message: String
    let systemImage: String
    let accentColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

private struct FlexibleTagWrap: View {
    let items: [String]
    let selectedItems: Set<String>
    let onTap: (String) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 112), spacing: 10)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
            ForEach(items, id: \.self) { item in
                Button {
                    onTap(item)
                } label: {
                    Text(item)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                        .foregroundStyle(selectedItems.contains(item) ? .white : .primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(
                            Capsule()
                                .fill(selectedItems.contains(item) ? Color.black : Color(.tertiarySystemFill))
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

