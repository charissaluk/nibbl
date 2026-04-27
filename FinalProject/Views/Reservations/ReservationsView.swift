//
//  ReservationsView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//

import SwiftUI
import SwiftData
import UIKit

struct ReservationsView: View {
    @Query(sort: \Reservation.reservationDate, order: .forward) private var reservations: [Reservation]

    @State private var selectedMode: ReservationDisplayMode = .list
    @State private var visibleMonth = Date()
    @State private var selectedDate = Date()

    private enum ReservationDisplayMode: String, CaseIterable, Identifiable {
        case list = "List"
        case calendar = "Calendar"

        var id: String { rawValue }
    }

    private var upcomingReservations: [Reservation] {
        reservations
            .filter { $0.effectiveStatus != "completed" }
            .sorted { $0.reservationDate < $1.reservationDate }
    }

    private var pastReservations: [Reservation] {
        reservations
            .filter { $0.effectiveStatus == "completed" }
            .sorted { $0.reservationDate > $1.reservationDate }
    }

    var body: some View {
        VStack(spacing: 0) {
            Picker("View", selection: $selectedMode) {
                ForEach(ReservationDisplayMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 20)
            .padding(.top, 12)

            if selectedMode == .list {
                listView
            } else {
                calendarView
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reservations")
        .navigationBarTitleDisplayMode(.large)
    }

    private var listView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                reservationSection(
                    title: "Upcoming",
                    emptyMessage: "No upcoming reservations yet.",
                    reservations: upcomingReservations
                )

                reservationSection(
                    title: "Past",
                    emptyMessage: "Past reservations will show up here.",
                    reservations: pastReservations
                )
            }
            .padding(20)
        }
    }

    private var calendarView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                calendarHeader
                monthGrid
                selectedDayAgenda
            }
            .padding(20)
        }
    }

    private func reservationSection(
        title: String,
        emptyMessage: String,
        reservations: [Reservation]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.title3.weight(.semibold))

            if reservations.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(reservations) { reservation in
                        NavigationLink {
                            ReservationDetailView(reservation: reservation)
                        } label: {
                            ReservationRow(reservation: reservation)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var calendarHeader: some View {
        HStack {
            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: -1, to: visibleMonth) ?? visibleMonth
            } label: {
                Image(systemName: "chevron.left")
                    .font(.headline)
            }

            Spacer()

            Text(visibleMonth.formatted(.dateTime.month(.wide).year()))
                .font(.title3.weight(.semibold))

            Spacer()

            Button {
                visibleMonth = Calendar.current.date(byAdding: .month, value: 1, to: visibleMonth) ?? visibleMonth
            } label: {
                Image(systemName: "chevron.right")
                    .font(.headline)
            }
        }
        .buttonStyle(.plain)
    }

    private var monthGrid: some View {
        let calendar = Calendar.current
        let days = daysInVisibleMonth()
        let firstWeekdayOffset = firstWeekdayOffsetForVisibleMonth()

        return VStack(spacing: 12) {
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Color.clear
                        .frame(height: 44)
                }

                ForEach(days, id: \.self) { date in
                    let dayReservations = reservationsForDay(date)

                    Button {
                        selectedDate = date
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.subheadline.weight(calendar.isDateInToday(date) ? .bold : .medium))
                                .foregroundStyle(calendar.isDateInToday(date) ? .white : .primary)
                                .frame(width: 30, height: 30)
                                .background(
                                    Circle()
                                        .fill(calendar.isDateInToday(date) ? Color.red : Color.clear)
                                )

                            HStack(spacing: 3) {
                                ForEach(Array(dayReservations.prefix(3).enumerated()), id: \.offset) { _, reservation in
                                    Circle()
                                        .fill(statusColor(for: reservation))
                                        .frame(width: 5, height: 5)
                                }
                            }
                            .frame(height: 6)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color(.secondarySystemBackground) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var selectedDayAgenda: some View {
        let dayReservations = reservationsForDay(selectedDate)
            .sorted { $0.reservationDate < $1.reservationDate }

        return VStack(alignment: .leading, spacing: 14) {
            Text(selectedDate.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                .font(.title3.weight(.semibold))

            if dayReservations.isEmpty {
                Text("No reservations on this day.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(dayReservations) { reservation in
                        NavigationLink {
                            ReservationDetailView(reservation: reservation)
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                Text(reservation.reservationDate.formatted(.dateTime.hour().minute()))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 72, alignment: .leading)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(reservation.restaurantName)
                                        .font(.headline)

                                    Text(reservation.restaurantAddress)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Circle()
                                    .fill(statusColor(for: reservation))
                                    .frame(width: 10, height: 10)
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

    private func daysInVisibleMonth() -> [Date] {
        let calendar = Calendar.current
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: visibleMonth),
            let dayRange = calendar.range(of: .day, in: .month, for: visibleMonth)
        else {
            return []
        }

        return dayRange.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start)
        }
    }

    private func firstWeekdayOffsetForVisibleMonth() -> Int {
        let calendar = Calendar.current
        guard let monthStart = calendar.dateInterval(of: .month, for: visibleMonth)?.start else {
            return 0
        }

        return calendar.component(.weekday, from: monthStart) - 1
    }

    private func reservationsForDay(_ date: Date) -> [Reservation] {
        reservations.filter {
            Calendar.current.isDate($0.reservationDate, inSameDayAs: date)
        }
    }

    private func statusColor(for reservation: Reservation) -> Color {
        switch reservation.effectiveStatus {
        case "confirmed":
            return .green
        case "cancelled":
            return .red
        case "completed":
            return .gray
        default:
            return .yellow
        }
    }
}

private struct ReservationRow: View {
    let reservation: Reservation

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 6) {
                Text(reservation.restaurantName)
                    .font(.headline)

                Text("\(reservation.restaurantCuisine) • \(reservation.mode.capitalized)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(reservation.reservationDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "message.fill")
                .foregroundStyle(.blue)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statusColor: Color {
        switch reservation.effectiveStatus {
        case "confirmed":
            return .green
        case "cancelled":
            return .red
        case "completed":
            return .gray
        default:
            return .yellow
        }
    }
}

private struct ReservationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var reservation: Reservation

    @State private var draftMessage = ""
    @State private var feedbackMessage: String?
    @State private var showCancelConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                headerCard
                statusCard
                chatSection
                bookingSection
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Reservation Plan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(reservation.restaurantName)
                .font(.system(size: 28, weight: .bold))

            Text("\(reservation.restaurantCuisine) • \(reservation.mode.capitalized)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(reservation.restaurantAddress)
                .font(.caption)
                .foregroundStyle(.secondary)

            DatePicker(
                "Reservation time",
                selection: $reservation.reservationDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .onChange(of: reservation.reservationDate) { _, _ in
                save()
            }
        }
        .padding(20)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var statusCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Status")
                    .font(.headline)

                Text(statusText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(statusText)
                .font(.caption.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(statusColor.opacity(0.18), in: Capsule())
                .foregroundStyle(statusColor)
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var chatSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "message.fill")
                    .foregroundStyle(.blue)

                Text("Coordinate")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(reservation.messages.enumerated()), id: \.offset) { _, message in
                    Text(message)
                        .font(.subheadline)
                        .padding(12)
                        .background(
                            message.hasPrefix("You:")
                                ? Color.blue.opacity(0.16)
                                : Color(.secondarySystemBackground),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .frame(maxWidth: .infinity, alignment: message.hasPrefix("You:") ? .trailing : .leading)
                }
            }

            HStack(spacing: 10) {
                TextField("Message", text: $draftMessage)
                    .textFieldStyle(.roundedBorder)

                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .disabled(draftMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var bookingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Booking")
                .font(.headline)

            if !reservation.acceptsReservations {
                Text("This restaurant is not currently accepting reservations.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Button {
                    confirmReservation()
                } label: {
                    Label("Confirm with Mock Backend", systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)

                if let urlString = reservation.bookingURLString,
                   let url = URL(string: urlString) {
                    Button {
                        UIApplication.shared.open(url)
                    } label: {
                        Label("Open External Booking Site", systemImage: "safari.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Button {
                showCancelConfirmation = true
            } label: {
                Label("Cancel Reservation", systemImage: "xmark.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.red.opacity(0.12), in: RoundedRectangle(cornerRadius: 18))
                    .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
            .confirmationDialog(
                "Are you sure you want to cancel your reservation?",
                isPresented: $showCancelConfirmation,
                titleVisibility: .visible
            ) {
                Button("Yes, cancel reservation", role: .destructive) {
                    deleteReservation()
                }

                Button("No", role: .cancel) { }
            }
            .buttonStyle(.plain)

            if let feedbackMessage {
                Text(feedbackMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var statusText: String {
        switch reservation.effectiveStatus {
        case "confirmed":
            return "Confirmed"
        case "cancelled":
            return "Cancelled"
        case "completed":
            return "Completed"
        default:
            return "In Progress"
        }
    }

    private var statusColor: Color {
        switch reservation.effectiveStatus {
        case "confirmed":
            return .green
        case "cancelled":
            return .red
        case "completed":
            return .gray
        default:
            return .yellow
        }
    }

    private func sendMessage() {
        let trimmed = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        reservation.messages.append("You: \(trimmed)")
        draftMessage = ""
        save()
    }

    private func confirmReservation() {
        guard reservation.acceptsReservations else {
            feedbackMessage = "This restaurant is not currently accepting reservations."
            return
        }

        reservation.status = "confirmed"
        reservation.messages.append("Nibbl: Reservation confirmed through the mock backend.")
        feedbackMessage = "Reservation confirmed."
        save()
    }

    private func deleteReservation() {
        modelContext.delete(reservation)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            feedbackMessage = "Could not cancel reservation."
        }
    }

    private func save() {
        do {
            try modelContext.save()
        } catch {
            feedbackMessage = "Could not save reservation changes."
        }
    }
}
