//
//  AddToListSheetView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/22/26.
//


import SwiftUI
import SwiftData

struct AddToListSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RestaurantList.createdAt, order: .reverse) private var lists: [RestaurantList]

    let restaurant: Restaurant

    @State private var newListName: String = ""
    @State private var feedbackMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    createListSection
                    existingListsSection

                    if let feedbackMessage {
                        Text(feedbackMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Add to List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var createListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Create a new list")
                .font(.headline)

            TextField("List name", text: $newListName)
                .textFieldStyle(.roundedBorder)

            Button {
                createListAndAddRestaurant()
            } label: {
                Text("Create and Add")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color(.systemBackground))
        )
    }

    private var existingListsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Existing lists")
                .font(.headline)

            if lists.isEmpty {
                Text("No lists yet. Create one above to get started.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(.systemBackground))
                    )
            } else {
                ForEach(lists) { list in
                    Button {
                        addRestaurant(to: list)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(list.name)
                                    .font(.headline)

                                Text("\(list.restaurants.count) restaurant\(list.restaurants.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: list.restaurants.contains(where: { $0.id == restaurant.id }) ? "checkmark.circle.fill" : "plus.circle")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Color(.systemBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func createListAndAddRestaurant() {
        let trimmed = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existingList = lists.first(where: { list in
            list.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }) {
            addRestaurant(to: existingList)
            newListName = ""
            return
        }

        let list = RestaurantList(name: trimmed)

        if !list.restaurants.contains(where: { existingRestaurant in
            existingRestaurant.id == restaurant.id
        }) {
            list.restaurants.append(restaurant)
        }

        modelContext.insert(list)

        do {
            try modelContext.save()
            feedbackMessage = "Added to \(trimmed)."
            newListName = ""
        } catch {
            feedbackMessage = "Could not create the list."
        }
    }

    private func addRestaurant(to list: RestaurantList) {
        guard !list.restaurants.contains(where: { $0.id == restaurant.id }) else {
            feedbackMessage = "Already in \(list.name)."
            return
        }

        list.restaurants.append(restaurant)

        do {
            try modelContext.save()
            feedbackMessage = "Added to \(list.name)."
        } catch {
            feedbackMessage = "Could not add to \(list.name)."
        }
    }
}

