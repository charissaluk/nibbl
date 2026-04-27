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

    @State private var newListName = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    createListSection
                    existingListsSection
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
                    .background(Color.black, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
            .disabled(newListName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(18)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
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
                    .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 22))
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
                        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func createListAndAddRestaurant() {
        let trimmed = newListName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let existing = lists.first(where: {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines)
                .localizedCaseInsensitiveCompare(trimmed) == .orderedSame
        }) {
            addRestaurant(to: existing)
            return
        }

        let list = RestaurantList(name: trimmed, restaurants: [restaurant])
        modelContext.insert(list)

        saveAndDismiss()
    }

    private func addRestaurant(to list: RestaurantList) {
        guard !list.restaurants.contains(where: { $0.id == restaurant.id }) else {
            dismiss()
            return
        }

        list.restaurants.append(restaurant)
        saveAndDismiss()
    }

    private func saveAndDismiss() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("LIST SAVE ERROR:", error)
        }
    }
}
