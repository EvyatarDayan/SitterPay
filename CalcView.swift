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
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                Text(currencySymbol)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appRed)
                Text(String(format: "%.2f", totalPay))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appRed)
            }
            .frame(minWidth: 200)
        }
    }
    
    private var durationDisplay: some View {
        VStack(spacing: 4) {
            Text("duration".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.primary)
            Text(formatDuration(duration))
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
    
    private var babysitterNameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("babysitter_name".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                TextField("babysitter_name".localized, text: $babysitterName)
                    .font(.body)
                    .focused($focusedField, equals: .babysitterName)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(showValidationError && babysitterName.isEmpty ? Color.red : Color.clear, lineWidth: 2)
                    )
                
                Button(action: {
                    showBabysitterSelection = true
                }) {
                    Image("nanny")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(Color.appRed)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.appRed.opacity(0.1))
                        .cornerRadius(8)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 85)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var payFields: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("pay_per_hour".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        TextField("0.00", text: $hourlyRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .focused($focusedField, equals: .hourlyRate)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(showValidationError && (hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)) == nil) ? Color.red : Color.clear, lineWidth: 2)
                            )
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
                        Text(currencySymbol)
                            .foregroundColor(.secondary)
                            .font(.body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 0.5)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("other_pays".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        TextField("0.00", text: $otherPays)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .focused($focusedField, equals: .otherPays)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: otherPays) { oldValue, newValue in
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    otherPays = filtered
                                }
                                if isSaved && oldValue != newValue {
                                    isSaved = false
                                }
                            }
                        Text(currencySymbol)
                            .foregroundColor(.secondary)
                            .font(.body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 85)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var timeFields: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("start_time".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showStartTimePicker = true
                    }) {
                        HStack {
                            Text(timeFormatter.string(from: startTime))
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 0.5)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("end_time".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showEndTimePicker = true
                    }) {
                        HStack {
                            Text(timeFormatter.string(from: endTime))
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 85)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var saveButton: some View {
        Button(action: {
            saveToHistory()
        }) {
            Text("save_to_history".localized)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canSaveToHistory && !isSaved ? Color.appRed : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!canSaveToHistory || isSaved)
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                        totalPayDisplay
                            .padding(.top, 20)
                        
                        durationDisplay
                        
                        babysitterNameField
                        
                        payFields
                        
                        timeFields
                        
                        if !isTimeValid {
                            Text("end_time_must_be_after_start_time".localized)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                saveButton
            }
            .onChange(of: startTime) { oldValue, newValue in
                // Reset saved state when field changes
                if isSaved && oldValue != newValue {
                    isSaved = false
                }
            }
            .onChange(of: endTime) { oldValue, newValue in
                // Reset saved state when field changes
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
            }
            .navigationTitle("calculate".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("reset".localized) { clearAllFields() }
                        .foregroundColor(Color.appRed)
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
        }
    }
}

