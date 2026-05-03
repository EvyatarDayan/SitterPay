//
//  HistoryManager.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import Foundation
import SwiftUI

class HistoryManager: ObservableObject {
    @Published var records: [PaymentRecord] = []
    
    private let allRecordsKey = "AllPaymentRecords"
    
    init() {
        loadRecords()
    }
    
    func addRecord(_ record: PaymentRecord) {
        // Load all records, add new one, save all
        var allRecords = loadAllRecords()
        allRecords.append(record)
        saveAllRecords(allRecords)
        
        // Reload records
        loadRecords()
    }
    
    func deleteRecord(_ record: PaymentRecord) {
        // Load all records, remove the one matching id, save all
        var allRecords = loadAllRecords()
        allRecords.removeAll { $0.id == record.id }
        saveAllRecords(allRecords)
        
        // Reload current user's records
        loadRecords()
    }
    
    func updatePaidStatus(for record: PaymentRecord, isPaid: Bool) {
        // Load all records, update the one matching id, save all
        var allRecords = loadAllRecords()
        if let index = allRecords.firstIndex(where: { $0.id == record.id }) {
            var updatedRecord = allRecords[index]
            updatedRecord = PaymentRecord(
                id: updatedRecord.id,
                userId: updatedRecord.userId,
                babysitterName: updatedRecord.babysitterName,
                hourlyRate: updatedRecord.hourlyRate,
                otherPays: updatedRecord.otherPays,
                totalPay: updatedRecord.totalPay,
                startTime: updatedRecord.startTime,
                endTime: updatedRecord.endTime,
                duration: updatedRecord.duration,
                date: updatedRecord.date,
                currencyCode: updatedRecord.currencyCode,
                isPaid: isPaid,
                tipPercentage: updatedRecord.tipPercentage,
                eventId: updatedRecord.eventId
            )
            allRecords[index] = updatedRecord
            saveAllRecords(allRecords)
            
            // Reload current user's records
            loadRecords()
        }
    }
    
    func updateTip(for record: PaymentRecord, tipPercentage: Double?) {
        // Load all records, update the one matching id, save all
        var allRecords = loadAllRecords()
        if let index = allRecords.firstIndex(where: { $0.id == record.id }) {
            var updatedRecord = allRecords[index]
            
            // Calculate base pay (without tip)
            var basePay = updatedRecord.totalPay
            if let oldTip = updatedRecord.tipPercentage {
                // Remove old tip: basePay = totalPay / (1 + tip/100)
                basePay = updatedRecord.totalPay / (1 + oldTip / 100.0)
            }
            
            // Calculate new total pay with tip
            var newTotalPay = basePay
            if let tip = tipPercentage {
                // Add new tip
                newTotalPay = basePay * (1 + tip / 100.0)
            }
            
            updatedRecord = PaymentRecord(
                id: updatedRecord.id,
                userId: updatedRecord.userId,
                babysitterName: updatedRecord.babysitterName,
                hourlyRate: updatedRecord.hourlyRate,
                otherPays: updatedRecord.otherPays,
                totalPay: newTotalPay,
                startTime: updatedRecord.startTime,
                endTime: updatedRecord.endTime,
                duration: updatedRecord.duration,
                date: updatedRecord.date,
                currencyCode: updatedRecord.currencyCode,
                isPaid: updatedRecord.isPaid,
                tipPercentage: tipPercentage,
                eventId: updatedRecord.eventId
            )
            allRecords[index] = updatedRecord
            saveAllRecords(allRecords)
            
            // Reload current user's records
            loadRecords()
        }
    }
    
    func updateEvent(for record: PaymentRecord, eventId: UUID?) {
        // Load all records, update the one matching id, save all
        var allRecords = loadAllRecords()
        if let index = allRecords.firstIndex(where: { $0.id == record.id }) {
            var updatedRecord = allRecords[index]
            updatedRecord = PaymentRecord(
                id: updatedRecord.id,
                userId: updatedRecord.userId,
                babysitterName: updatedRecord.babysitterName,
                hourlyRate: updatedRecord.hourlyRate,
                otherPays: updatedRecord.otherPays,
                totalPay: updatedRecord.totalPay,
                startTime: updatedRecord.startTime,
                endTime: updatedRecord.endTime,
                duration: updatedRecord.duration,
                date: updatedRecord.date,
                currencyCode: updatedRecord.currencyCode,
                isPaid: updatedRecord.isPaid,
                tipPercentage: updatedRecord.tipPercentage,
                eventId: eventId
            )
            allRecords[index] = updatedRecord
            saveAllRecords(allRecords)
            
            // Reload current user's records
            loadRecords()
        }
    }
    
    private func saveAllRecords(_ records: [PaymentRecord]) {
        if let encoded = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(encoded, forKey: allRecordsKey)
        }
    }
    
    private func loadAllRecords() -> [PaymentRecord] {
        if let data = UserDefaults.standard.data(forKey: allRecordsKey),
           let decoded = try? JSONDecoder().decode([PaymentRecord].self, from: data) {
            return decoded
        }
        return []
    }
    
    func loadRecords() {
        // Load all records
        let allRecords = loadAllRecords()
        
        // Update on main thread to ensure UI updates
        if Thread.isMainThread {
            records = allRecords
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.records = allRecords
            }
        }
    }
    
    func updateAllRecordsCurrency(to newCurrencyCode: String) {
        // Load all records, update currency code for all records, save all
        var allRecords = loadAllRecords()
        
        // Update currency code for all records
        for index in allRecords.indices {
            let record = allRecords[index]
            allRecords[index] = PaymentRecord(
                id: record.id,
                userId: record.userId,
                babysitterName: record.babysitterName,
                hourlyRate: record.hourlyRate,
                otherPays: record.otherPays,
                totalPay: record.totalPay,
                startTime: record.startTime,
                endTime: record.endTime,
                duration: record.duration,
                date: record.date,
                currencyCode: newCurrencyCode,
                isPaid: record.isPaid,
                tipPercentage: record.tipPercentage,
                eventId: record.eventId
            )
        }
        
        saveAllRecords(allRecords)
        
        // Reload records - ensure on main thread for UI updates
        // Use DispatchQueue.main.async to ensure UI updates happen after the save completes
        DispatchQueue.main.async { [weak self] in
            self?.loadRecords()
            // Post notification to trigger view refreshes
            NotificationCenter.default.post(name: NSNotification.Name("CurrencyDidChange"), object: nil)
        }
    }
}

