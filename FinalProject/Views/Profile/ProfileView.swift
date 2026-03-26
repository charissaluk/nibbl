//
//  ProfileView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//


import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var restaurants: [Restaurant]
    @StateObject private var viewModel: ProfileViewModel

    init() {
        _viewModel = StateObject(wrappedValue: ProfileViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                profileHeader
                statsSection
                savedSection
                visitedSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.reload(from: restaurants)
        }
        .onChange(of: restaurants.count) { _, _ in
            viewModel.reload(from: restaurants)
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.black, Color.gray.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 82, height: 82)

                Image(systemName: "person.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Your Food Profile")
                    .font(.title2.weight(.bold))

                Text("Saved spots, visited places, and the beginning of your restaurant graph.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }

    private var statsSection: some View {
        HStack(spacing: 14) {
            StatCard(
                title: "Saved",
                value: "\(viewModel.stats.savedCount)",
                subtitle: "restaurants"
            )

            StatCard(
                title: "Visited",
                value: "\(viewModel.stats.visitedCount)",
                subtitle: "restaurants"
            )
        }
    }

    private var savedSection: some View {
        profileSection(
            title: "Saved restaurants",
            emptyTitle: "No saved restaurants yet",
            emptySubtitle: "Once you save places from search or planning, they’ll show up here.",
            restaurants: Array(viewModel.savedRestaurants.prefix(4))
        )
    }

    private var visitedSection: some View {
        profileSection(
            title: "Visited restaurants",
            emptyTitle: "No visited restaurants yet",
            emptySubtitle: "Mark places as visited later to build your dining history.",
            restaurants: Array(viewModel.visitedRestaurants.prefix(4))
        )
    }

    private func profileSection(
        title: String,
        emptyTitle: String,
        emptySubtitle: String,
        restaurants: [Restaurant]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))

            if restaurants.isEmpty {
                EmptyProfileCard(
                    title: emptyTitle,
                    subtitle: emptySubtitle
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(restaurants) { restaurant in
                        ProfileRestaurantRow(restaurant: restaurant)
                    }
                }
            }
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 30, weight: .bold))

            Text(subtitle)
                .font(.caption)
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

private struct ProfileRestaurantRow: View {
    let restaurant: Restaurant

    var body: some View {
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

                Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(restaurant.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }
}

private struct EmptyProfileCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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