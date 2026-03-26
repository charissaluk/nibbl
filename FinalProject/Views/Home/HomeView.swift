//
//  HomeView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: HomeViewModel

    init() {
        _viewModel = StateObject(wrappedValue: HomeViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                recentActivitySection
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Find your next spot")
                    .font(.system(size: 30, weight: .bold))

                Text("See where your friends have been and start a plan when you’re ready.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                appState.switchToTab(.plan)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start a Plan Session")
                            .font(.headline)

                        Text("Choose for me, solo or with friends")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                }
                .foregroundStyle(.white)
                .padding(18)
                .background(
                    LinearGradient(
                        colors: [Color.black, Color.gray.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Recent activity")
                    .font(.title3.weight(.semibold))

                Spacer()

                Text("\(viewModel.feedItems.count) posts")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVStack(spacing: 16) {
                ForEach(viewModel.feedItems, id: \.id) { item in
                    NavigationLink {
                        RestaurantDetailView(restaurant: item.asRestaurant)
                    } label: {
                        FeedCardView(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
