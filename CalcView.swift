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
    @State private var isSaved: Bool = false
    @State private var showBabysitterSelection: Bool = false
    @StateObject private var babysitterManager = BabysitterManager()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case hourlyRate, otherPays
    }
    
    private let calcFieldHeight: CGFloat = 52
    private let calcTimeFieldHeight: CGFloat = 72
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var selectedCurrency: Currency {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode }) ?? Currency.allCurrencies[0]
    }
    
    private var currencySymbol: String {
        selectedCurrency.displaySymbol
    }
    
    private var durationHours: Double {
        max(0, endTime.timeIntervalSince(startTime) / 3600.0)
    }
    
    private var duration: TimeInterval {
        max(0, endTime.timeIntervalSince(startTime))
    }
    
    private var totalPay: Double {
        let hourlyRateValue = hourlyRate.paymentAmountValue ?? 0.0
        let otherPaysValue = otherPays.paymentAmountValue ?? 0.0
        return (hourlyRateValue * durationHours) + otherPaysValue
    }
    
    private var isTimeValid: Bool {
        endTime > startTime
    }
    
    private var canSaveToHistory: Bool {
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmedName.isEmpty && !trimmedRate.isEmpty && trimmedRate.paymentAmountValue != nil && !isSaved && isTimeValid
    }
    
    private func getDefaultStartTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        components.second = 0
        return calendar.date(from: components) ?? now
    }
    
    private func getDefaultEndTime() -> Date {
        calendar.date(byAdding: .hour, value: 4, to: getDefaultStartTime()) ?? getDefaultStartTime()
    }
    
    private var calendar: Calendar { Calendar.current }
    
    private func clearAllFields() {
        hourlyRate = ""
        otherPays = ""
        babysitterName = ""
        startTime = getDefaultStartTime()
        endTime = getDefaultEndTime()
        focusedField = nil
        isSaved = false
    }
    
    private func saveToHistory() {
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty || trimmedRate.isEmpty || trimmedRate.paymentAmountValue == nil {
            showValidationError = true
            return
        }
        
        showValidationError = false
        
        let record = PaymentRecord(
            userId: UUID(),
            babysitterName: babysitterName,
            hourlyRate: hourlyRate.paymentAmountValue ?? 0.0,
            otherPays: otherPays.paymentAmountValue ?? 0.0,
            totalPay: totalPay,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            date: Date(),
            currencyCode: selectedCurrencyCode
        )
        
        historyManager.addRecord(record)
        isSaved = true
        showSaveSuccess = true
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    resultHeroCard
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 12) {
                        babysitterCard
                        ratesCard
                        timeCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .navigationTitle("calculate".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("reset".localized) {
                        clearAllFields()
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done".localized) { focusedField = nil }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: saveToHistory) {
                    Text("save_to_history".localized)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(canSaveToHistory && !isSaved ? Color.appRed : Color.gray)
                        .clipShape(Capsule())
                }
                .disabled(!canSaveToHistory || isSaved)
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
            }
            .onChange(of: startTime) { _, _ in
                if isSaved { isSaved = false }
            }
            .onChange(of: endTime) { _, _ in
                if isSaved { isSaved = false }
            }
            .sheet(isPresented: $showStartTimePicker) {
                timePickerSheet(selection: $startTime)
            }
            .sheet(isPresented: $showEndTimePicker) {
                timePickerSheet(selection: $endTime)
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
                            hourlyRate = PaymentFormat.amount(rate)
                        }
                        if let other = babysitter.otherPays {
                            otherPays = PaymentFormat.amount(other)
                        }
                        showValidationError = false
                        if isSaved { isSaved = false }
                        showBabysitterSelection = false
                    }
                )
            }
            .id(localizationManager.currentLanguage)
        }
    }
    
    // MARK: - Cards
    
    private var resultHeroCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(currencySymbol)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                Text(PaymentFormat.amount(totalPay))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
            }
            .foregroundColor(Color.appRed)
            .contentTransition(.numericText())
            
            HStack(spacing: 0) {
                summaryMetric(
                    icon: "Duration",
                    label: "duration".localized,
                    value: DurationFormat.compact(duration)
                )
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 1, height: 36)
                
                summaryMetric(
                    icon: "Payment",
                    label: "pay_per_hour".localized,
                    value: hourlyRate.isEmpty ? "—" : PaymentFormat.currency(hourlyRate.paymentAmountValue ?? 0, symbol: currencySymbol)
                )
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .calcCardStyle()
    }
    
    private func summaryMetric(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.secondary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var babysitterCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardSectionHeader(title: "babysitter_information".localized)
            
            Button {
                showBabysitterSelection = true
            } label: {
                HStack(spacing: 10) {
                    Text(babysitterName.isEmpty ? "select_babysitter_placeholder".localized : babysitterName)
                        .font(.body)
                        .foregroundColor(babysitterName.isEmpty ? .secondary : .primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image("nanny")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.appRed)
                        .padding(10)
                        .background(Color.appRed.opacity(0.12))
                        .cornerRadius(10)
                }
                .padding(.horizontal, 12)
                .frame(height: calcFieldHeight)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(showValidationError && babysitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color.clear, lineWidth: 1.5)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .calcCardStyle()
    }
    
    private var ratesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardSectionHeader(title: "payment_information".localized)
            
            HStack(spacing: 12) {
                rateField(
                    title: "hourly_rate".localized,
                    text: $hourlyRate,
                    field: .hourlyRate,
                    showError: showValidationError && (hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines).paymentAmountValue == nil)
                )
                
                rateField(
                    title: "other_pays".localized,
                    text: $otherPays,
                    field: .otherPays,
                    showError: false
                )
            }
        }
        .padding(16)
        .calcCardStyle()
    }
    
    private func rateField(title: String, text: Binding<String>, field: Field, showError: Bool) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                Text(currencySymbol)
                    .foregroundColor(.secondary)
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
            }
            .padding(.horizontal, 12)
            .frame(height: calcFieldHeight)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(showError ? Color.red : Color.clear, lineWidth: 1.5)
            )
            .onChange(of: text.wrappedValue) { oldValue, newValue in
                let filtered = newValue.filteringPaymentInput()
                if filtered != newValue {
                    text.wrappedValue = filtered
                }
                if showValidationError && !newValue.isEmpty && newValue.paymentAmountValue != nil {
                    showValidationError = false
                }
                if isSaved && oldValue != newValue {
                    isSaved = false
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var timeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            CardSectionHeader(title: "time".localized)
            
            HStack(spacing: 12) {
                timeField(
                    title: "start_time".localized,
                    date: $startTime,
                    showPicker: { showStartTimePicker = true }
                )
                
                timeField(
                    title: "end_time".localized,
                    date: $endTime,
                    showPicker: { showEndTimePicker = true }
                )
            }
            
            if !isTimeValid {
                Text("end_time_must_be_after_start_time".localized)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding(16)
        .calcCardStyle()
    }
    
    private func adjustTime(_ date: Binding<Date>, byMinutes minutes: Int) {
        guard let newDate = calendar.date(byAdding: .minute, value: minutes, to: date.wrappedValue) else { return }
        date.wrappedValue = newDate
        if isSaved { isSaved = false }
    }
    
    private func timeField(title: String, date: Binding<Date>, showPicker: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Button(action: showPicker) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(timeFormatter.string(from: date.wrappedValue))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.appRed)
                    
                    Text(dateFormatter.string(from: date.wrappedValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 4) {
                Button {
                    adjustTime(date, byMinutes: 30)
                } label: {
                    Image(systemName: "chevron.up")
                        .font(.caption.weight(.semibold))
                        .frame(width: 32, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                Button {
                    adjustTime(date, byMinutes: -30)
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.semibold))
                        .frame(width: 32, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            .foregroundColor(.appRed)
        }
        .padding(.horizontal, 12)
        .frame(height: calcTimeFieldHeight)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    private func timePickerSheet(selection: Binding<Date>) -> some View {
        VStack(spacing: 0) {
            DatePicker("", selection: selection, displayedComponents: [.date, .hourAndMinute])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(height: 200)
        }
        .presentationDetents([.height(250)])
        .presentationDragIndicator(.visible)
    }
}
