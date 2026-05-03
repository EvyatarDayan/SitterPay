//
//  Babysitter.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import Foundation

struct Babysitter: Identifiable, Codable, Equatable {
    var id: UUID
    var userId: UUID
    var name: String
    var address: String
    var phoneNumber: String
    var email: String
    var hourlyRate: Double?
    var otherPays: Double?
    
    init(id: UUID = UUID(), userId: UUID, name: String, address: String, phoneNumber: String, email: String, hourlyRate: Double? = nil, otherPays: Double? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.address = address
        self.phoneNumber = phoneNumber
        self.email = email
        self.hourlyRate = hourlyRate
        self.otherPays = otherPays
    }
}

