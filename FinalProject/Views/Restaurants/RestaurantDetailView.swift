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
import OSLog

struct RestaurantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @Query(sort: \Restaurant.createdAt, order: .reverse) private var savedRestaurants: [Restaurant]

    let restaurant: Restaurant

    @State private var persistedRestaurant: Restaurant?
    @State private var selectedRestaurantForList: Restaurant?
    @State private var selectedRestaurantForReservation: Restaurant?
    @State private var feedbackMessage: String?
    private let logger = Logger(subsystem: "Nibbl", category: "Persistence")
    

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
        .sheet(item: $selectedRestaurantForList) { restaurant in
            AddToListSheetView(restaurant: restaurant)
        }
        .sheet(item: $selectedRestaurantForReservation) { restaurant in
            NavigationStack {
                MockReservationBookingView(restaurant: restaurant)
                    .environmentObject(appState)
            }
        }
        .onAppear {
            persistedRestaurant = matchingPersistedRestaurant()
        }
    }

    private var isSaved: Bool {
        matchingPersistedRestaurant()?.isSaved == true
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
                    Label("Save", systemImage: isSaved ? "bookmark.fill" : "bookmark")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(isSaved ? Color.blue : Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(isSaved ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .foregroundStyle(isSaved ? .white : .black)
                }
                .buttonStyle(.plain)

                Button {
                    if let persisted = ensurePersistedRestaurant() {
                        selectedRestaurantForList = persisted
                    }
                } label: {
                    Label("Add to List", systemImage: "text.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                        )
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }

            Button {
                if let persisted = ensurePersistedRestaurant() {
                    selectedRestaurantForReservation = persisted
                }
            } label: {
                Label("Reserve Now", systemImage: "calendar.badge.plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)

            Button {
                openInMaps()
            } label: {
                Label("Open in Apple Maps", systemImage: "arrow.up.right.square.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
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
        savedRestaurants.first { saved in
            normalized(saved.name) == normalized(restaurant.name)
            &&
            normalized(saved.address) == normalized(restaurant.address)
        }
    }

    private func normalized(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    @discardableResult
    private func ensurePersistedRestaurant() -> Restaurant? {
        if let existing = matchingPersistedRestaurant() {
            persistedRestaurant = existing
            return existing
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
            return saved
        } catch {
            feedbackMessage = "Could not save restaurant."
            logger.error("Failed to save restaurant: \(error.localizedDescription, privacy: .public)")
            return nil
        }
    }

    private func toggleSave() {
        if let existing = matchingPersistedRestaurant() {
            existing.isSaved.toggle()
            persistedRestaurant = existing
        } else if let created = ensurePersistedRestaurant() {
            created.isSaved = true
            persistedRestaurant = created
        }

        do {
            try modelContext.save()
            feedbackMessage = isSaved ? "Saved restaurant." : "Removed from saved restaurants."
        } catch {
            feedbackMessage = "Could not update saved status."
            logger.error("Failed to update saved status: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func openInMaps() {
        if let url = AppleMapsURLBuilder.url(for: restaurant) {
            UIApplication.shared.open(url)
        }
    }
}

private struct MockReservationBookingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState

    let restaurant: Restaurant

    @State private var selectedDate = Date()
    @State private var selectedTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var partySize = 2
    @State private var selectedSlot: Date?
    @State private var feedbackMessage: String?
    private let logger = Logger(subsystem: "Nibbl", category: "Reservations")

    private var acceptsReservations: Bool {
        MockReservationBackend.acceptsReservations(for: restaurant)
    }

    private var availableSlots: [Date] {
        guard acceptsReservations else { return [] }

        let calendar = Calendar.current
        let selectedComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
        let hour = selectedComponents.hour ?? 17
        let minute = selectedComponents.minute ?? 0

        let roundedMinute = (minute / 15) * 15

        guard var current = calendar.date(
            bySettingHour: hour,
            minute: roundedMinute,
            second: 0,
            of: selectedDate
        ) else {
            return []
        }

        guard let closing = calendar.date(bySettingHour: 21, minute: 0, second: 0, of: selectedDate) else {
            return []
        }

        if current < Date() {
            current = calendar.date(byAdding: .day, value: 1, to: current) ?? current
        }

        var slots: [Date] = []

        while current <= closing {
            slots.append(current)
            guard let next = calendar.date(byAdding: .minute, value: 15, to: current) else {
                break
            }
            current = next
        }

        return slots
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                inputsSection
                availableTimesSection
                createButton

                if let feedbackMessage {
                    Text(feedbackMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reserve")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(restaurant.name)
                .font(.system(size: 28, weight: .bold))

            Text("\(restaurant.cuisine) • \(restaurant.priceTier)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if !acceptsReservations {
                Text("This restaurant is not currently accepting reservations.")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.red)
                    .padding(.top, 4)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24))
    }

    private var inputsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reservation Details")
                .font(.headline)

            DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])

            DatePicker("Start time", selection: $selectedTime, displayedComponents: [.hourAndMinute])

            Stepper("Party of \(partySize)", value: $partySize, in: 1...12)
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
    }

    private var availableTimesSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Available Times")
                .font(.headline)

            if availableSlots.isEmpty {
                Text("No times available.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(availableSlots, id: \.self) { slot in
                            Button {
                                selectedSlot = slot
                            } label: {
                                Text(slot.formatted(date: .omitted, time: .shortened))
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        selectedSlot == slot ? Color.black : Color(.secondarySystemBackground),
                                        in: Capsule()
                                    )
                                    .foregroundStyle(selectedSlot == slot ? .white : .primary)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Reservation time \(slot.formatted(date: .omitted, time: .shortened))")
                            .accessibilityAddTraits(selectedSlot == slot ? [.isSelected] : [])
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
    }

    private var createButton: some View {
        Button {
            createReservation()
        } label: {
            Text("Create Reservation")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    acceptsReservations && selectedSlot != nil ? Color.green : Color.gray,
                    in: RoundedRectangle(cornerRadius: 18)
                )
                .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .disabled(!acceptsReservations || selectedSlot == nil)
    }

    private func createReservation() {
        guard let selectedSlot else {
            feedbackMessage = "Choose a time first."
            return
        }

        let reservationDate = selectedSlot < Date()
            ? Calendar.current.date(byAdding: .day, value: 1, to: selectedSlot) ?? selectedSlot
            : selectedSlot

        let reservation = Reservation(
            restaurantID: restaurant.id,
            planningSessionID: UUID(),
            restaurantName: restaurant.name,
            restaurantCuisine: restaurant.cuisine,
            restaurantAddress: restaurant.address,
            restaurantLatitude: restaurant.latitude,
            restaurantLongitude: restaurant.longitude,
            mode: "individual",
            reservationDate: reservationDate,
            status: "confirmed",
            acceptsReservations: acceptsReservations,
            bookingProvider: MockReservationBackend.providerName(for: restaurant),
            bookingURLString: MockReservationBackend.bookingURLString(for: restaurant),
            messages: [
                "Nibbl: Reservation created for \(partySize) people.",
                "Nibbl: \(reservationDate.formatted(date: .abbreviated, time: .shortened))"
            ]
        )

        modelContext.insert(reservation)

        do {
            try modelContext.save()
            dismiss()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                appState.switchToTab(.reservations)
            }
        } catch {
            feedbackMessage = "Could not create reservation."
            logger.error("Failed to create reservation: \(error.localizedDescription, privacy: .public)")
        }
    }
}

enum AppleMapsURLBuilder {
    static func url(for restaurant: Restaurant) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(restaurant.latitude),\(restaurant.longitude)"),
            URLQueryItem(name: "q", value: restaurant.name)
        ]
        return components.url
    }
}
