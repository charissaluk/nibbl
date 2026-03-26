//
//  SwipeCardView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//
import SwiftUI

struct SwipeCardView: View {
    let recommendation: RecommendationResult
    let matchPercentage: Int
    let explanationLines: [String]
    let onOpenMaps: () -> Void

    @State private var isFlipped = false

    var body: some View {
        ZStack {
            if isFlipped {
                backCard
                    .transition(.opacity)
            } else {
                frontCard
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 560)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 10)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.35), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }

    private var frontCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
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
                    .frame(height: 270)
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "fork.knife.circle.fill")
                                .font(.system(size: 60))
                                .symbolRenderingMode(.hierarchical)

                            Text(recommendation.restaurant.cuisine)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                    }

                if recommendation.restaurant.isSaved {
                    Label("Saved", systemImage: "bookmark.fill")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(14)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(recommendation.restaurant.name)
                    .font(.title2.weight(.bold))

                Text("\(recommendation.restaurant.cuisine) • \(recommendation.restaurant.priceTier)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 10) {
                    Label(
                        DistanceFormatter.milesString(from: recommendation.restaurant.distanceFromUser),
                        systemImage: "location"
                    )
                    .font(.caption)

                    if let neighborhood = recommendation.restaurant.neighborhood {
                        Label(neighborhood, systemImage: "mappin.and.ellipse")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("\(matchPercentage)% match")
                    .font(.headline)

                ForEach(explanationLines.prefix(3), id: \.self) { line in
                    Text(line)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("Tap to flip")
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(18)
    }

    private var backCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(recommendation.restaurant.name)
                .font(.title2.weight(.bold))
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

            Group {
                infoRow(title: "Address", value: recommendation.restaurant.address)
                infoRow(title: "Cuisine", value: recommendation.restaurant.cuisine)
                infoRow(title: "Price", value: recommendation.restaurant.priceTier)
                infoRow(
                    title: "Neighborhood",
                    value: recommendation.restaurant.neighborhood ?? "Nearby"
                )
                infoRow(
                    title: "Notes",
                    value: recommendation.restaurant.notes ?? "No extra notes yet."
                )
            }
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))

            Spacer()

            Button {
                onOpenMaps()
            } label: {
                HStack {
                    Text("Open in Apple Maps")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "arrow.up.right.square.fill")
                }
                .foregroundStyle(.white)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.black)
                )
            }
            .buttonStyle(.plain)
            .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        .padding(18)
    }

    private func infoRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
        }
    }
}
