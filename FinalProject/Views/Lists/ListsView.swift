//
//  ListsView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/20/26.
//
import SwiftUI
import SwiftData

struct ListsView: View {
    @Query(sort: \RestaurantList.createdAt, order: .reverse) private var lists: [RestaurantList]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection

                if lists.isEmpty {
                    emptyState
                } else {
                    listsSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Lists")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Lists")
                .font(.system(size: 28, weight: .bold))

            Text("Curate date-night ideas, neighborhood favorites, and places you want to try next.")
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

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("No lists yet")
                .font(.headline)

            Text("Once you start saving places into custom collections, your restaurant lists will show up here.")
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

    private var listsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("All lists")
                .font(.title3.weight(.semibold))

            VStack(spacing: 12) {
                ForEach(lists) { list in
                    NavigationLink {
                        ListDetailView(list: list)
                    } label: {
                        ListCardView(list: list)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct ListCardView: View {
    let list: RestaurantList

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(list.name)
                    .font(.headline)

                Spacer()

                Text("\(list.restaurants.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(list.restaurants.count == 1 ? "1 restaurant" : "\(list.restaurants.count) restaurants")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !list.restaurants.isEmpty {
                Text(list.restaurants.prefix(3).map(\.name).joined(separator: " • "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
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
