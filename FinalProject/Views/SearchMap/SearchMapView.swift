//
//  SearchMapView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/20/26.
//
import SwiftUI
import SwiftData
import MapKit
import CoreLocation

struct SearchMapView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var savedRestaurants: [Restaurant]

    @StateObject private var viewModel: SearchMapViewModel
    @StateObject private var locationManager = LocationManager()

    @State private var cameraPosition: MapCameraPosition
    @State private var selectedRestaurant: Restaurant?
    @State private var hasCenteredOnUserLocation = false

    private let cuisineOptions: [String] = [
        "Japanese", "Korean", "Chinese", "Thai", "Vietnamese",
        "Pizza", "Tacos", "Fast Casual", "Halal",
        "French", "Italian", "Steakhouse", "Wine Bar", "Omakase",
        "American", "Mediterranean", "Indian", "Mexican", "Cafe", "Restaurant"
    ]

    init() {
        let initialRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 39.3299, longitude: -76.6205),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )

        _viewModel = StateObject(wrappedValue: SearchMapViewModel())
        _cameraPosition = State(initialValue: .region(initialRegion))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                mapSection
                resultsSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Search")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $viewModel.isShowingFilters) {
            FilterSheetView(
                filters: viewModel.filters,
                availableCuisines: cuisineOptions,
                onApply: { filters in
                    viewModel.filters = filters
                },
                onReset: {
                    viewModel.resetFilters()
                }
            )
        }
        .onAppear {
            locationManager.requestLocationAccess()
        }
        .onReceive(locationManager.$location) { location in
            viewModel.userLocation = location

            guard let location, !hasCenteredOnUserLocation else { return }
            centerMap(on: location.coordinate)
            hasCenteredOnUserLocation = true
        }
    }

    private var mapSection: some View {
        ZStack(alignment: .top) {
            Map(position: $cameraPosition) {
                ForEach(viewModel.visibleResults) { restaurant in
                    Annotation(
                        restaurant.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: restaurant.latitude,
                            longitude: restaurant.longitude
                        )
                    ) {
                        Button {
                            selectedRestaurant = restaurant
                        } label: {
                            VStack(spacing: 4) {
                                Image(systemName: selectedRestaurant?.id == restaurant.id ? "fork.knife.circle.fill" : "fork.knife.circle")
                                    .font(.title2)
                                    .foregroundStyle(.black)
                                    .padding(6)
                                    .background(Circle().fill(Color.white))

                                if selectedRestaurant?.id == restaurant.id {
                                    Text(restaurant.name)
                                        .font(.caption2.weight(.semibold))
                                        .lineLimit(1)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(.ultraThinMaterial, in: Capsule())
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(height: 360)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .onMapCameraChange { context in
                viewModel.region = context.region
            }

            VStack(spacing: 10) {
                searchBar
                controlsRow

                if viewModel.isLoading {
                    Label("Searching…", systemImage: "magnifyingglass")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground), in: Capsule())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemBackground), in: Capsule())
                }
            }
            .padding(14)

            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    Spacer()

                    Button {
                        recenterMapOnUser()
                    } label: {
                        Image(systemName: "location.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .background(Color(.systemBackground), in: Circle())
                            .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 14)
                    .padding(.bottom, selectedRestaurant == nil ? 14 : 110)
                }
            }

            if let selectedRestaurant {
                VStack {
                    Spacer()

                    selectedRestaurantCard(selectedRestaurant)
                        .padding(14)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search restaurants, cuisines, or vibes", text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.searchCurrentQuery()
                    }
                }

            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 48)
        .background(Color(.systemBackground).opacity(0.94), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }

    private var controlsRow: some View {
        HStack(spacing: 10) {
            Button {
                viewModel.isShowingFilters = true
            } label: {
                Label("Filters", systemImage: "slider.horizontal.3")
                    .font(.subheadline.weight(.semibold))
                    .frame(height: 44)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground).opacity(0.94), in: Capsule())
            }
            .buttonStyle(.plain)

            Button {
                Task {
                    await viewModel.searchThisArea()
                }
            } label: {
                Label(viewModel.isLoading ? "Searching" : "Search Area", systemImage: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .frame(height: 44)
                    .padding(.horizontal, 14)
                    .background(Color(.systemBackground).opacity(0.94), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)

            Spacer()
        }
    }
    
    private func recenterMapOnUser() {
        guard let location = locationManager.location ?? viewModel.userLocation else { return }

        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )

        viewModel.region = region

        withAnimation(.easeInOut(duration: 0.25)) {
            cameraPosition = .region(region)
        }
    }

    private func selectedRestaurantCard(_ restaurant: Restaurant) -> some View {
        NavigationLink {
            RestaurantDetailView(restaurant: resolvedRestaurantForDetail(restaurant))
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }

                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(DistanceFormatter.milesString(from: restaurant.distanceFromUser))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Results")
                    .font(.title3.weight(.semibold))

                Spacer()

                Text("\(viewModel.visibleResults.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage = viewModel.errorMessage {
                SearchStateCard(
                    title: "Search unavailable",
                    subtitle: errorMessage,
                    systemImage: "wifi.exclamationmark"
                )
            } else if viewModel.isLoading && viewModel.visibleResults.isEmpty {
                SearchStateCard(
                    title: "Searching…",
                    subtitle: "Looking for restaurants in the current map area.",
                    systemImage: "magnifyingglass"
                )
            } else if viewModel.visibleResults.isEmpty {
                SearchStateCard(
                    title: "No restaurants yet",
                    subtitle: "Try searching this area or broaden your filters.",
                    systemImage: "fork.knife.circle"
                )
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.visibleResults, id: \.id) { restaurant in
                        NavigationLink {
                            RestaurantDetailView(restaurant: resolvedRestaurantForDetail(restaurant))
                        } label: {
                            SearchResultCard(
                                restaurant: restaurant,
                                isSaved: isRestaurantSaved(restaurant),
                                onSaveTapped: {
                                    saveRestaurantIfNeeded(restaurant)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func centerMap(on coordinate: CLLocationCoordinate2D) {
        viewModel.region.center = coordinate
        cameraPosition = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            )
        )
    }

    private func resolvedRestaurantForDetail(_ restaurant: Restaurant) -> Restaurant {
        savedRestaurants.first {
            $0.name == restaurant.name && $0.address == restaurant.address
        } ?? restaurant
    }

    private func isRestaurantSaved(_ restaurant: Restaurant) -> Bool {
        savedRestaurants.contains {
            $0.name == restaurant.name && $0.address == restaurant.address
        }
    }

    private func saveRestaurantIfNeeded(_ restaurant: Restaurant) {
        guard !isRestaurantSaved(restaurant) else { return }

        let saved = Restaurant(
            name: restaurant.name,
            cuisine: restaurant.cuisine,
            priceTier: restaurant.priceTier,
            latitude: restaurant.latitude,
            longitude: restaurant.longitude,
            address: restaurant.address,
            rating: restaurant.rating,
            distanceFromUser: restaurant.distanceFromUser,
            neighborhood: restaurant.neighborhood,
            isSaved: true,
            isVisited: restaurant.isVisited,
            notes: restaurant.notes
        )

        modelContext.insert(saved)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save restaurant: \(error)")
        }
    }
}

private struct SearchStateCard: View {
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

private struct SearchResultCard: View {
    let restaurant: Restaurant
    let isSaved: Bool
    let onSaveTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant.name)
                        .font(.headline)

                    Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let neighborhood = restaurant.neighborhood {
                        Text(neighborhood)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(DistanceFormatter.milesString(from: restaurant.distanceFromUser))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onSaveTapped()
                } label: {
                    Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundStyle(isSaved ? .black : .secondary)
                }
                .buttonStyle(.plain)
            }

            Text(restaurant.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let rating = restaurant.rating {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", rating))
                        .font(.caption.weight(.semibold))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

