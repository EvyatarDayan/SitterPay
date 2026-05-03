//
//  PaymentRecord.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import Foundation

struct PaymentRecord: Identifiable, Codable {
    let id: UUID
    let userId: UUID // User who owns this record
    let babysitterName: String
    let hourlyRate: Double
    let otherPays: Double
    let totalPay: Double
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let date: Date
    let currencyCode: String
    let isPaid: Bool // Payment status
    let tipPercentage: Double? // Tip percentage (5, 10, 20)
    let eventId: UUID? // Associated event ID
    
    init(id: UUID = UUID(), userId: UUID, babysitterName: String, hourlyRate: Double, otherPays: Double, totalPay: Double, startTime: Date, endTime: Date, duration: TimeInterval, date: Date = Date(), currencyCode: String, isPaid: Bool = false, tipPercentage: Double? = nil, eventId: UUID? = nil) {
        self.id = id
        self.userId = userId
        self.babysitterName = babysitterName
        self.hourlyRate = hourlyRate
        self.otherPays = otherPays
        self.totalPay = totalPay
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.date = date
        self.currencyCode = currencyCode
        self.isPaid = isPaid
        self.tipPercentage = tipPercentage
        self.eventId = eventId
    }
}

