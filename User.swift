//
//  User.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var firstName: String
    var lastName: String
    let email: String
    var password: String // In production, this should be hashed
    var profileImageData: Data?
    var avatarName: String?
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    init(id: UUID = UUID(), firstName: String, lastName: String, email: String, password: String, profileImageData: Data? = nil, avatarName: String? = nil) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.profileImageData = profileImageData
        self.avatarName = avatarName
    }
}





