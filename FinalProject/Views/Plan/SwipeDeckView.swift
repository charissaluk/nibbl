//
//  SwipeDeckView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//

import UIKit
import SwiftUI
import SwiftData
import MapKit

struct SwipeDeckView: View {
    @Environment(\.modelContext) private var modelContext

    @StateObject private var viewModel: SwipeDeckViewModel
    @State private var dragOffset: CGSize = .zero
    @State private var showSummary = false

    init(
        session: PlanningSession,
        candidateRestaurants: [Restaurant]
    ) {
        _viewModel = StateObject(
            wrappedValue: SwipeDeckViewModel(
                session: session,
                candidateRestaurants: candidateRestaurants
            )
        )
    }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                headerSection

                if let recommendation = viewModel.currentRecommendation {
                    SwipeCardView(
                        recommendation: recommendation,
                        matchPercentage: viewModel.displayMatchPercentage(for: recommendation),
                        explanationLines: viewModel.explanationLines(for: recommendation),
                        onOpenMaps: {
                            openInMaps(recommendation.restaurant)
                        }
                    )
                    .offset(dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset.width / 14)))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation
                            }
                            .onEnded { value in
                                handleSwipeEnd(value.translation)
                            }
                    )
                    .animation(.spring(response: 0.28, dampingFraction: 0.82), value: dragOffset)

                    swipeHints
                } else {
                    emptyDeckState
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .navigationTitle("Swipe")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showSummary) {
            PlanSummaryView(
                session: viewModel.session,
                likedRecommendations: viewModel.likedRecommendations
            )
        }
        .onAppear {
            viewModel.markFinishedIfNeeded()
            if viewModel.hasFinished {
                showSummary = true
            }
        }
        .onChange(of: viewModel.hasFinished) { _, finished in
            if finished {
                showSummary = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Choose your favorites")
                .font(.title2.weight(.bold))

            Text("\(viewModel.remainingCount) left • swipe through saved and nearby restaurant ideas")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var swipeHints: some View {
        HStack {
            hintCapsule(title: "Pass", systemImage: "xmark")
            Spacer()
            hintCapsule(title: "Like", systemImage: "heart.fill")
        }
    }

    private var emptyDeckState: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)

            Text("You’re done swiping")
                .font(.headline)

            Text("Your summary is ready.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxHeight: .infinity)
    }

    private func hintCapsule(title: String, systemImage: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.secondarySystemBackground), in: Capsule())
    }

    private func handleSwipeEnd(_ translation: CGSize) {
        let threshold: CGFloat = 110

        if translation.width > threshold {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                dragOffset = CGSize(width: 800, height: translation.height)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                viewModel.recordSwipe(direction: .right, context: modelContext)
                dragOffset = .zero
            }
        } else if translation.width < -threshold {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                dragOffset = CGSize(width: -800, height: translation.height)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                viewModel.recordSwipe(direction: .left, context: modelContext)
                dragOffset = .zero
            }
        } else {
            withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                dragOffset = .zero
            }
        }
    }

    private func openInMaps(_ restaurant: Restaurant) {
        if let url = AppleMapsURLBuilder.url(for: restaurant) {
            UIApplication.shared.open(url)
        }
    }
}
