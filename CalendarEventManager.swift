//
//  CalendarEventManager.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-12-06.
//

import Foundation
import SwiftUI

class CalendarEventManager: ObservableObject {
    @Published var events: [CalendarEvent] = []
    
    private let allEventsKey = "AllCalendarEvents"
    
    init() {
        loadEvents()
    }
    
    func addEvent(_ event: CalendarEvent) {
        // Load all events, add new one, save all
        var allEvents = loadAllEvents()
        allEvents.append(event)
        saveAllEvents(allEvents)
        
        // Reload events
        loadEvents()
    }
    
    func deleteEvent(_ event: CalendarEvent) {
        var allEvents = loadAllEvents()
        allEvents.removeAll { $0.id == event.id }
        saveAllEvents(allEvents)
        
        // Reload current user's events
        loadEvents()
    }
    
    func updateEvent(_ event: CalendarEvent) {
        var allEvents = loadAllEvents()
        if let index = allEvents.firstIndex(where: { $0.id == event.id }) {
            allEvents[index] = event
            saveAllEvents(allEvents)
            loadEvents()
        }
    }
    
    func eventsForDate(_ date: Date) -> [CalendarEvent] {
        let calendar = Calendar.current
        return events.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    private func saveAllEvents(_ events: [CalendarEvent]) {
        if let encoded = try? JSONEncoder().encode(events) {
            UserDefaults.standard.set(encoded, forKey: allEventsKey)
        }
    }
    
    private func loadAllEvents() -> [CalendarEvent] {
        if let data = UserDefaults.standard.data(forKey: allEventsKey),
           let decoded = try? JSONDecoder().decode([CalendarEvent].self, from: data) {
            return decoded
        }
        return []
    }
    
    private func loadEvents() {
        let allEvents = loadAllEvents()
        events = allEvents
    }
}

