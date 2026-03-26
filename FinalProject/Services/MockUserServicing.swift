//
//  MockUserServicing.swift
//  FinalProject
//
//  Created by Charissa Luk on 3/19/26.
//


import Foundation

protocol MockUserServicing {
    func fetchAllUsers() -> [MockUserProfile]
    func fetchUsers(withIDs ids: [String]) -> [MockUserProfile]
    func fetchUser(withID id: String) -> MockUserProfile?
}

struct MockUserService: MockUserServicing {
    func fetchAllUsers() -> [MockUserProfile] {
        MockUserProfile.allMockUsers
    }

    func fetchUsers(withIDs ids: [String]) -> [MockUserProfile] {
        let idSet = Set(ids)
        return MockUserProfile.allMockUsers.filter { idSet.contains($0.id) }
    }

    func fetchUser(withID id: String) -> MockUserProfile? {
        MockUserProfile.allMockUsers.first(where: { $0.id == id })
    }
}
