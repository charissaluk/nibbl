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
    @Query(sort: \RestaurantList.createdAt, order: .reverse) private var lists: [RestaurantList]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                profileHeader
                listsSection
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
                value: "\(savedRestaurants.count)",
                subtitle: "restaurants"
            )

            StatCard(
                title: "Visited",
                value: "\(visitedRestaurants.count)",
                subtitle: "restaurants"
            )
        }
    }

    private var savedSection: some View {
        profileSection(
            title: "Saved restaurants",
            emptyTitle: "No saved restaurants yet",
            emptySubtitle: "Once you save places from search or planning, they’ll show up here.",
            restaurants: Array(savedRestaurants.prefix(4))
        )
    }

    private var visitedSection: some View {
        profileSection(
            title: "Visited restaurants",
            emptyTitle: "No visited restaurants yet",
            emptySubtitle: "Mark places as visited later to build your dining history.",
            restaurants: Array(visitedRestaurants.prefix(4))
        )
    }
    
    private var listsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Lists")
                .font(.title3.weight(.semibold))

            if lists.isEmpty {
                EmptyProfileCard(
                    title: "No lists yet",
                    subtitle: "Create lists from restaurant detail pages to organize places you want to try."
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(lists) { list in
                        NavigationLink {
                            ListDetailView(list: list)
                        } label: {
                            HStack(spacing: 14) {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color(.secondarySystemBackground))
                                    .frame(width: 56, height: 56)
                                    .overlay {
                                        Image(systemName: "bookmark.fill")
                                            .foregroundStyle(.secondary)
                                    }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(list.name)
                                        .font(.headline)

                                    Text("\(list.restaurants.count) restaurant\(list.restaurants.count == 1 ? "" : "s")")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(16)
                            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    private var savedRestaurants: [Restaurant] {
        restaurants.filter { $0.isSaved }
    }

    private var visitedRestaurants: [Restaurant] {
        restaurants.filter { $0.isVisited }
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
                        NavigationLink {
                            RestaurantDetailView(restaurant: restaurant)
                        } label: {
                            ProfileRestaurantRow(restaurant: restaurant)
                        }
                        .buttonStyle(.plain)
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
