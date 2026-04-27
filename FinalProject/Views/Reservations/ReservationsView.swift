//
//  ReservationsView.swift
//  FinalProject
//
//  Created by Charissa Luk on 4/26/26.
//


//
//  ReservationsView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//

import SwiftUI
import SwiftData

struct ReservationsView: View {
    @Query(sort: \Reservation.reservationDate, order: .forward) private var reservations: [Reservation]
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var restaurants: [Restaurant]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if reservations.isEmpty {
                    emptyState
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(reservations) { reservation in
                            ReservationRow(
                                reservation: reservation,
                                restaurant: restaurant(for: reservation.restaurantID)
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 36)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reservations")
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Reservation Drafts")
                .font(.system(size: 28, weight: .bold))

            Text("Plans you create from swipe summaries show up here so you can keep track of next steps.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
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
        VStack(alignment: .leading, spacing: 8) {
            Text("No reservation drafts yet")
                .font(.headline)

            Text("Create a reservation from a plan summary when your group lands on a top match.")
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

    private func restaurant(for id: UUID) -> Restaurant? {
        restaurants.first { $0.id == id }
    }
}

private struct ReservationRow: View {
    let reservation: Reservation
    let restaurant: Restaurant?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(restaurant?.name ?? "Restaurant")
                        .font(.headline)

                    if let restaurant {
                        Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Text(reservation.status.capitalized)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemFill), in: Capsule())
            }

            Label(reservation.reservationDate.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                .font(.caption)
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
