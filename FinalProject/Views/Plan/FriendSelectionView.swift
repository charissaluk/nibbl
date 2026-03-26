//
//  FriendSelectionView.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/25/26.
//


import SwiftUI

struct FriendSelectionView: View {
    let friends: [MockUserProfile]
    let selectedFriendIDs: Set<String>
    let onToggle: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Choose friends")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(friends, id: \.id) { friend in
                    Button {
                        onToggle(friend.id)
                    } label: {
                        FriendCard(
                            friend: friend,
                            isSelected: selectedFriendIDs.contains(friend.id)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct FriendCard: View {
    let friend: MockUserProfile
    let isSelected: Bool

    private var summaryText: String {
        let cuisines = friend.preferredCuisines.prefix(2).joined(separator: ", ")
        return "\(cuisines) • \(friend.minPrice)-\(friend.maxPrice)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: isSelected
                                    ? [Color.black, Color.gray]
                                    : [Color.orange.opacity(0.85), Color.pink.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Text(String(friend.name.prefix(1)))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }

            Text(friend.name)
                .font(.headline)

            Text(summaryText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Text(friend.vibePreferences.prefix(2).joined(separator: " • "))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isSelected ? Color(.secondarySystemBackground) : Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isSelected ? Color.black.opacity(0.25) : Color.black.opacity(0.06), lineWidth: 1)
        )
        .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: 10, x: 0, y: 6)
    }
}

