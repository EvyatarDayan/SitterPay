//
//  CalcView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct CalcView: View {
    @ObservedObject var historyManager: HistoryManager
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var hourlyRate: String = ""
    @State private var otherPays: String = ""
    @State private var babysitterName: String = ""
    @State private var startTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }()
    @State private var endTime: Date = {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        components.second = 0
        let startDate = calendar.date(from: components) ?? now
        return calendar.date(byAdding: .hour, value: 4, to: startDate) ?? now
    }()
    @State private var showStartTimePicker: Bool = false
    @State private var showEndTimePicker: Bool = false
    @State private var showSaveSuccess: Bool = false
    @State private var showValidationError: Bool = false
    @State private var isSaved: Bool = false // Track if current data was saved
    @State private var showBabysitterSelection: Bool = false
    @StateObject private var babysitterManager = BabysitterManager()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case hourlyRate, otherPays, babysitterName
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
    
    private var selectedCurrency: Currency {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode }) ?? Currency.allCurrencies[0]
    }
    
    private var currencySymbol: String {
        selectedCurrency.displaySymbol
    }
    
    // Calculate duration in hours
    private var durationHours: Double {
        let duration = endTime.timeIntervalSince(startTime)
        return max(0, duration / 3600.0)
    }
    
    // Calculate duration as TimeInterval
    private var duration: TimeInterval {
        return max(0, endTime.timeIntervalSince(startTime))
    }
    
    // Format duration from TimeInterval to readable format
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)

        var parts: [String] = []
        if hours > 0 {
            let hourText = hours == 1 ? "hour".localized : "hours".localized
            parts.append("\(hours) \(hourText)")
        }
        if minutes > 0 {
            let minuteText = minutes == 1 ? "minute".localized : "minutes".localized
            parts.append("\(minutes) \(minuteText)")
        }

        if parts.isEmpty {
            return "0 \("minutes".localized)"
        }

        return parts.joined(separator: " \("and".localized) ")
    }
    
    // Calculate total pay
    private var totalPay: Double {
        let hourlyRateValue = Double(hourlyRate) ?? 0.0
        let otherPaysValue = Double(otherPays) ?? 0.0
        return (hourlyRateValue * durationHours) + otherPaysValue
    }
    
    // Check if end time is after start time
    private var isTimeValid: Bool {
        return endTime > startTime
    }
    
    // Check if save button should be enabled
    private var canSaveToHistory: Bool {
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedRate.isEmpty && Double(trimmedRate) != nil && !isSaved && isTimeValid
    }
    
    // Get default start time (today at 20:00)
    private func getDefaultStartTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }
    
    // Get default end time (4 hours after start time)
    private func getDefaultEndTime() -> Date {
        let calendar = Calendar.current
        let startDate = getDefaultStartTime()
        return calendar.date(byAdding: .hour, value: 4, to: startDate) ?? startDate
    }
    
    // Clear all fields
    private func clearAllFields() {
        hourlyRate = ""
        otherPays = ""
        babysitterName = ""
        startTime = getDefaultStartTime()
        endTime = getDefaultEndTime()
        focusedField = nil
        isSaved = false // Reset saved state when clearing
    }
    
    // Save to history
    private func saveToHistory() {
        // Always validate first, even if button appears disabled
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty || trimmedRate.isEmpty || Double(trimmedRate) == nil {
            showValidationError = true
            return
        }
        
        showValidationError = false
        
        let hourlyRateValue = Double(hourlyRate) ?? 0.0
        let otherPaysValue = Double(otherPays) ?? 0.0
        let finalDuration = duration
        let finalPay = totalPay
        
        let record = PaymentRecord(
            userId: UUID(), // Dummy UUID for backward compatibility
            babysitterName: babysitterName,
            hourlyRate: hourlyRateValue,
            otherPays: otherPaysValue,
            totalPay: finalPay,
            startTime: startTime,
            endTime: endTime,
            duration: finalDuration,
            date: Date(),
            currencyCode: selectedCurrencyCode
        )
        
        historyManager.addRecord(record)
        isSaved = true // Mark as saved
        showSaveSuccess = true
    }
    
    // MARK: - View Components
    
    private var totalPayDisplay: some View {
        VStack(spacing: 8) {
            Text("total_pay".localized)
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                Text(currencySymbol)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appRed)
                Text(String(format: "%.2f", totalPay))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appRed)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private var durationDisplay: some View {
        VStack(spacing: 4) {
            Text("duration".localized)
                .font(.headline)
                .foregroundColor(.primary)
            Text(formatDuration(duration))
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        totalPayDisplay
                        durationDisplay
                    }
                    
                    Section("babysitter_information".localized) {
                        HStack {
                            TextField("babysitter_name_placeholder".localized, text: $babysitterName)
                                .focused($focusedField, equals: .babysitterName)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.words)
                            
                            Button(action: {
                                showBabysitterSelection = true
                            }) {
                                Image("nanny")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.appRed)
                            }
                        }
                        .onChange(of: babysitterName) { oldValue, newValue in
                            if showValidationError && !babysitterName.isEmpty {
                                showValidationError = false
                            }
                            if isSaved && oldValue != newValue {
                                isSaved = false
                            }
                        }
                    }
                    
                    Section("payment_information".localized) {
                        TextField("hourly_rate".localized, text: $hourlyRate)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .hourlyRate)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: hourlyRate) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    hourlyRate = filtered
                                }
                                if showValidationError && !newValue.isEmpty && Double(newValue) != nil {
                                    showValidationError = false
                                }
                                if isSaved && oldValue != newValue {
                                    isSaved = false
                                }
                            }
                        
                        TextField("other_pays".localized, text: $otherPays)
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .otherPays)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .onChange(of: otherPays) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    otherPays = filtered
                                }
                                if isSaved && oldValue != newValue {
                                    isSaved = false
                                }
                            }
                    }
                    
                    Section("time".localized) {
                        Button(action: {
                            showStartTimePicker = true
                        }) {
                            HStack {
                                Text("start_time".localized)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(timeFormatter.string(from: startTime))
                                    .foregroundColor(.appRed)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.appRed)
                            }
                        }
                        
                        Button(action: {
                            showEndTimePicker = true
                        }) {
                            HStack {
                                Text("end_time".localized)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(timeFormatter.string(from: endTime))
                                    .foregroundColor(.appRed)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.appRed)
                            }
                        }
                        
                        if !isTimeValid {
                            Text("end_time_must_be_after_start_time".localized)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .onChange(of: startTime) { oldValue, newValue in
                if isSaved && oldValue != newValue {
                    isSaved = false
                }
            }
            .onChange(of: endTime) { oldValue, newValue in
                if isSaved && oldValue != newValue {
                    isSaved = false
                }
            }
            .sheet(isPresented: $showStartTimePicker) {
                VStack(spacing: 0) {
                    DatePicker("", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 200)
                }
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showEndTimePicker) {
                VStack(spacing: 0) {
                    DatePicker("", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(height: 200)
                }
                .presentationDetents([.height(250)])
                .presentationDragIndicator(.visible)
            }
            .navigationTitle("calculate".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("reset".localized) {
                        clearAllFields()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("save_to_history".localized) {
                        saveToHistory()
                    }
                    .disabled(!canSaveToHistory || isSaved)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done".localized) { focusedField = nil }
                }
            }
            .alert("pay_saved_to_history".localized, isPresented: $showSaveSuccess) {
                Button("ok".localized) {
                    showSaveSuccess = false
                }
            }
            .sheet(isPresented: $showBabysitterSelection) {
                BabysitterSelectionView(
                    babysitterManager: babysitterManager,
                    onSelect: { babysitter in
                        babysitterName = babysitter.name
                        if let rate = babysitter.hourlyRate {
                            hourlyRate = String(format: "%.2f", rate)
                        }
                        if let other = babysitter.otherPays {
                            otherPays = String(format: "%.2f", other)
                        }
                        showBabysitterSelection = false
                    }
                )
            }
            .id(localizationManager.currentLanguage)
        }
    }
}

