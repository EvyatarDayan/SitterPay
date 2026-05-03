//
//  CalendarEvent.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-12-06.
//

import Foundation

struct CalendarEvent: Identifiable, Codable {
    let id: UUID
    let userId: UUID // User who owns this event
    let eventName: String
    let date: Date
    let startTime: Date?
    let babysitterName: String
    let payPerHour: Double
    let otherPays: Double
    let comments: String
    let isConfirmed: Bool
    let confirmedByName: String?
    
    init(id: UUID = UUID(), userId: UUID, eventName: String = "", date: Date, startTime: Date? = nil, babysitterName: String, payPerHour: Double, otherPays: Double, comments: String, isConfirmed: Bool = false, confirmedByName: String? = nil) {
        self.id = id
        self.userId = userId
        self.eventName = eventName
        self.date = date
        self.startTime = startTime
        self.babysitterName = babysitterName
        self.payPerHour = payPerHour
        self.otherPays = otherPays
        self.comments = comments
        self.isConfirmed = isConfirmed
        self.confirmedByName = confirmedByName
    }
}

