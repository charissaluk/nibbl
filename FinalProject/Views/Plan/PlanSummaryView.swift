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
    @EnvironmentObject private var appState: AppState
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var restaurants: [Restaurant]

    let session: PlanningSession
    let likedRecommendations: [RecommendationResult]

    @StateObject private var viewModel = PlanSummaryViewModel()
    @State private var showTopMatch = false

    private var savedRestaurants: [Restaurant] {
        restaurants.filter { $0.isSaved }
    }

    init(
        session: PlanningSession,
        likedRecommendations: [RecommendationResult]
    ) {
        self.session = session
        self.likedRecommendations = likedRecommendations
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
            refreshSummary()

            withAnimation(.easeOut(duration: 0.4)) {
                showTopMatch = true
            }
        }
        .onChange(of: restaurants.count) { _, _ in
            refreshSummary()
        }
    }

    private func refreshSummary() {
        viewModel.configure(
            session: session,
            likedRecommendations: likedRecommendations,
            savedRestaurants: savedRestaurants
        )
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

            VStack(alignment: .leading, spacing: 8) {
                ForEach(item.explanationLines, id: \.self) { line in
                    HStack(spacing: 8) {
                        Image(systemName: explanationIcon(for: line))
                            .foregroundStyle(explanationColor(for: line))

                        Text(cleanExplanation(line))
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
            }

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
                    appState.switchToTab(.reservations)
                } label: {
                    Text("Make Reservation")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.18), in: Capsule())
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
                .fill(matchGradient(for: item.matchPercentage))
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
                    .foregroundStyle(matchTextColor(for: item.matchPercentage))

                if let firstReason = item.explanationLines.first {
                    HStack(spacing: 5) {
                        Image(systemName: explanationIcon(for: firstReason))
                            .font(.caption)
                            .foregroundStyle(explanationColor(for: firstReason))

                        Text(cleanExplanation(firstReason))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
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

private func matchGradient(for percentage: Int) -> LinearGradient {
    if percentage >= 80 {
        return LinearGradient(
            colors: [Color.green.opacity(0.95), Color.green.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else if percentage >= 50 {
        return LinearGradient(
            colors: [Color.yellow.opacity(0.95), Color.orange.opacity(0.75)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    } else {
        return LinearGradient(
            colors: [Color.red.opacity(0.95), Color.red.opacity(0.65)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private func matchTextColor(for percentage: Int) -> Color {
    if percentage >= 80 {
        return .green
    } else if percentage >= 50 {
        return .orange
    } else {
        return .red
    }
}

private func explanationIcon(for line: String) -> String {
    line.hasPrefix("✕") ? "xmark.circle.fill" : "checkmark.circle.fill"
}

private func explanationColor(for line: String) -> Color {
    line.hasPrefix("✕") ? .red : .green
}

private func cleanExplanation(_ line: String) -> String {
    line
        .replacingOccurrences(of: "✓ ", with: "")
        .replacingOccurrences(of: "✕ ", with: "")
}
