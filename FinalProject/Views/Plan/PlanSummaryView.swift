//
//  PlanSummaryView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//
import SwiftUI
import SwiftData

struct PlanSummaryView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: PlanSummaryViewModel
    @State private var showTopMatch = false

    init(
        session: PlanningSession,
        likedRecommendations: [RecommendationResult]
    ) {
        _viewModel = StateObject(
            wrappedValue: PlanSummaryViewModel(
                session: session,
                likedRecommendations: likedRecommendations
            )
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let topMatch = viewModel.topMatch {
                    topMatchCard(topMatch)
                        .scaleEffect(showTopMatch ? 1 : 0.96)
                        .opacity(showTopMatch ? 1 : 0)
                }

                matchesSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Plan Summary")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                showTopMatch = true
            }
        }
    }

    private func topMatchCard(_ item: PlanSummaryViewModel.SummaryItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Top Match")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.85))

            Text(item.restaurant.name)
                .font(.system(size: 30, weight: .bold))
                .foregroundStyle(.white)

            Text("\(item.restaurant.cuisine) • \(item.restaurant.priceTier)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))

            Text("\(item.matchPercentage)% match")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                NavigationLink {
                    RestaurantDetailView(restaurant: item.restaurant)
                } label: {
                    Text("View Details")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.createReservationPlaceholder(for: item, context: modelContext)
                } label: {
                    Text("Create Reservation")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.15), in: Capsule())
                }
                .buttonStyle(.plain)
            }

            if let message = viewModel.reservationMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.9))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.black, Color.gray.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }

    private var matchesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Ranked Matches")
                .font(.title3.weight(.semibold))

            if viewModel.rankedMatches.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.rankedMatches) { item in
                        NavigationLink {
                            RestaurantDetailView(restaurant: item.restaurant)
                        } label: {
                            SummaryRow(item: item)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("No liked restaurants")
                .font(.headline)

            Text("Swipe right on a few restaurants first, then the summary will rank your best options.")
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

private struct SummaryRow: View {
    let item: PlanSummaryViewModel.SummaryItem

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
                .frame(width: 62, height: 62)
                .overlay {
                    Image(systemName: "fork.knife")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(item.restaurant.name)
                    .font(.headline)

                Text("\(item.restaurant.cuisine) • \(item.restaurant.priceTier)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(item.matchPercentage)% match")
                    .font(.caption.weight(.semibold))
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
}
