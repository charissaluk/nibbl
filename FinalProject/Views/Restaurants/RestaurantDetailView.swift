//
//  RestaurantDetailView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/22/26.
//

import UIKit
import SwiftUI
import SwiftData
import MapKit

struct RestaurantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var savedRestaurants: [Restaurant]

    let restaurant: Restaurant

    @State private var persistedRestaurant: Restaurant?
    @State private var isShowingAddToList = false
    @State private var feedbackMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                heroSection
                titleSection
                actionButtons
                detailSection
                notesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Restaurant")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingAddToList) {
            if let targetRestaurant = currentPersistedOrSourceRestaurant {
                AddToListSheetView(restaurant: targetRestaurant)
            }
        }
        .onAppear {
            persistedRestaurant = matchingPersistedRestaurant()
        }
    }

    private var currentPersistedOrSourceRestaurant: Restaurant? {
        persistedRestaurant ?? restaurant
    }

    private var isSaved: Bool {
        matchingPersistedRestaurant() != nil || restaurant.isSaved
    }

    private var heroSection: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color(.secondarySystemBackground),
                        Color(.tertiarySystemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: 260)
            .overlay {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 64))
                        .symbolRenderingMode(.hierarchical)

                    Text(restaurant.cuisine)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(restaurant.name)
                .font(.system(size: 30, weight: .bold))

            Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                if let neighborhood = restaurant.neighborhood {
                    Label(neighborhood, systemImage: "mappin.and.ellipse")
                }

                Label(
                    DistanceFormatter.milesString(from: restaurant.distanceFromUser),
                    systemImage: "location"
                )
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if let feedbackMessage {
                Text(feedbackMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    toggleSave()
                } label: {
                    Label(isSaved ? "Saved" : "Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color.black)
                        )
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                Button {
                    ensurePersistedRestaurant()
                    if matchingPersistedRestaurant() != nil {
                        isShowingAddToList = true
                    }
                } label: {
                    Label("Add to List", systemImage: "text.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }

            Button {
                openInMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "arrow.up.right.square.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Details")
                .font(.headline)

            detailRow(title: "Address", value: restaurant.address)
            detailRow(title: "Cuisine", value: restaurant.cuisine)
            detailRow(title: "Price Tier", value: restaurant.priceTier)
            detailRow(title: "Neighborhood", value: restaurant.neighborhood ?? "Nearby")
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Notes & vibe")
                .font(.headline)

            Text(restaurant.notes ?? "No extra notes yet. This area can later hold tags, vibe, and planning context.")
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

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
        }
    }

    private func matchingPersistedRestaurant() -> Restaurant? {
        savedRestaurants.first {
            $0.name == restaurant.name && $0.address == restaurant.address
        }
    }

    private func ensurePersistedRestaurant() {
        if let existing = matchingPersistedRestaurant() {
            persistedRestaurant = existing
            return
        }

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
            persistedRestaurant = saved
            feedbackMessage = "Saved restaurant."
        } catch {
            feedbackMessage = "Could not save restaurant."
        }
    }

    private func toggleSave() {
        if let existing = matchingPersistedRestaurant() {
            modelContext.delete(existing)

            do {
                try modelContext.save()
                persistedRestaurant = nil
                feedbackMessage = "Removed from saved restaurants."
            } catch {
                feedbackMessage = "Could not update saved status."
            }
        } else {
            ensurePersistedRestaurant()
        }
    }

    private func openInMaps() {
        let encodedName = restaurant.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Restaurant"
        let urlString = "http://maps.apple.com/?ll=\(restaurant.latitude),\(restaurant.longitude)&q=\(encodedName)"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
