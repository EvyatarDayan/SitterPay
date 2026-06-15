//
//  TemporaryView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-12-06.
//

import SwiftUI
import UserNotifications

struct TemporaryView: View {
    @StateObject private var eventManager = CalendarEventManager()
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    @State private var selectedDate: Date = Date()
    @State private var showAddEvent: Bool = false
    @State private var selectedEvent: CalendarEvent?
    
    private var selectedCurrency: Currency {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode }) ?? Currency.allCurrencies[0]
    }
    
    private var currencySymbol: String {
        selectedCurrency.displaySymbol
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        eventManager.eventsForDate(selectedDate)
    }
    
    // Check if selected date is in the past (before today)
    private var isSelectedDateInPast: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected < today
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Calendar
                    CalendarView(selectedDate: $selectedDate, eventManager: eventManager)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Events List
                    if eventsForSelectedDate.isEmpty {
                        VStack {
                            Spacer()
                            Text("no_events_for_this_date".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                            List {
                                ForEach(eventsForSelectedDate) { event in
                                    HStack(alignment: .center) {
                                        Text(event.eventName.isEmpty ? "event_name".localized : event.eventName)
                                            .font(.headline)
                                        
                                        Spacer()
                                        
                                        Text(event.babysitterName)
                                            .font(.headline)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .calcCardStyle()
                                    .listRowBackground(Color(.systemGroupedBackground))
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets.cardListRow)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedEvent = event
                                    }
                                }
                            }
                            .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("calendar".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Only allow adding events to today or future dates
                        if !isSelectedDateInPast {
                            showAddEvent = true
                        }
                    }) {
                        Image("Add")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(isSelectedDateInPast ? .gray : Color.appRed)
                    }
                    .disabled(isSelectedDateInPast)
                }
            }
            .sheet(isPresented: $showAddEvent) {
                AddEventView(eventManager: eventManager, selectedDate: selectedDate, currencySymbol: currencySymbol)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled()
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, eventManager: eventManager, currencySymbol: currencySymbol)
                    .presentationDetents([.large])
                    .interactiveDismissDisabled()
            }
        }
    }
}

// Calendar View Component
struct CalendarView: View {
    @Binding var selectedDate: Date
    @ObservedObject var eventManager: CalendarEventManager
    @State private var currentMonth: Date = Date()
    
    private let calendar = Calendar.current
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var daysInMonth: [Date] {
        guard let _ = calendar.dateInterval(of: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysToSubtract = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        guard let startDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: firstDay) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = startDate
        
        for _ in 0..<42 {
            days.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return days
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Month Navigation
            HStack {
                Button(action: {
                    if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.appRed)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: currentMonth))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
                        currentMonth = newMonth
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color.appRed)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
                ForEach(daysInMonth, id: \.self) { date in
                    let eventsForDay = eventManager.eventsForDate(date)
                    let hasEvents = !eventsForDay.isEmpty
                    let hasConfirmedEvents = eventsForDay.contains { $0.isConfirmed }
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasEvents: hasEvents,
                        hasConfirmedEvents: hasConfirmedEvents,
                        onTap: {
                            selectedDate = date
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .calcCardStyle()
    }
}

// Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let hasEvents: Bool
    let hasConfirmedEvents: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    private var dayNumber: Int {
        calendar.component(.day, from: date)
    }
    
    // Check if date is in the past (before today)
    private var isPastDate: Bool {
        let today = calendar.startOfDay(for: Date())
        let dateToCheck = calendar.startOfDay(for: date)
        return dateToCheck < today
    }
    
    private var eventColor: Color {
        if hasConfirmedEvents {
            return Color.appGreen
        } else if hasEvents {
            return Color.appRed
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                    .foregroundColor(
                        isPastDate ? .gray :
                        isCurrentMonth ? (isSelected ? .white : .primary) : .secondary
                    )
                
                if hasEvents {
                    Circle()
                        .fill(isSelected ? Color.white : (isPastDate ? Color.gray : eventColor))
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 44, height: 44)
            .background(isSelected ? (hasConfirmedEvents ? Color.appGreen : Color.appRed) : Color.clear)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Add Event View
struct AddEventView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var eventManager: CalendarEventManager
    let selectedDate: Date
    let currencySymbol: String
    
    @State private var eventName: String = ""
    @State private var babysitterName: String = ""
    @State private var payPerHour: String = ""
    @State private var otherPays: String = ""
    @State private var comments: String = ""
    @State private var eventDate: Date
    @State private var startTime: Date
    @State private var notifyMe: Bool = false
    @State private var isConfirmed: Bool = false
    @State private var showValidationError: Bool = false
    @State private var showBabysitterSelection: Bool = false
    @State private var isSaved: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var pdfURL: URL?
    @State private var shareCaption: String = ""
    @StateObject private var babysitterManager = BabysitterManager()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case eventName, babysitterName, payPerHour, otherPays, comments
    }
    
    init(eventManager: CalendarEventManager, selectedDate: Date, currencySymbol: String) {
        self.eventManager = eventManager
        self.selectedDate = selectedDate
        self.currencySymbol = currencySymbol
        _eventDate = State(initialValue: selectedDate)
        
        // Set default start time to 20:00
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = 20
        components.minute = 0
        components.second = 0
        let defaultStartTime = calendar.date(from: components) ?? Date()
        _startTime = State(initialValue: defaultStartTime)
    }
    
    private var canSave: Bool {
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !babysitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !payPerHour.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        payPerHour.paymentAmountValue != nil
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Event Information Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "event_information".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Event Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("event_name".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                TextField("event_name".localized, text: $eventName)
                                    .font(.body)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .focused($focusedField, equals: .eventName)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(showValidationError && eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color.clear, lineWidth: 2)
                                    )
                                    .onChange(of: eventName) { oldValue, newValue in
                                        if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            showValidationError = false
                                        }
                                    }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(height: 85)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Date and Start Time
                            HStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("date".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $eventDate, in: Date()..., displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.blue)
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .frame(height: 50)
                                
                                VStack(spacing: 4) {
                                    Text("start_time".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.blue)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Notify me checkbox
                            HStack {
                                Button(action: {
                                    notifyMe.toggle()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: notifyMe ? "checkmark.square.fill" : "square")
                                            .foregroundColor(notifyMe ? Color.appRed : .secondary)
                                            .font(.system(size: 20))
                                        Text("notify_me".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                    }
                                }
                                .buttonStyle(.plain)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Babysitter Information Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "babysitter_information".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Babysitter Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("babysitter_name".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 8) {
                                    TextField("babysitter_name".localized, text: $babysitterName)
                                        .font(.body)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .focused($focusedField, equals: .babysitterName)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(showValidationError && babysitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color.clear, lineWidth: 2)
                                        )
                                        .onChange(of: babysitterName) { oldValue, newValue in
                                            if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                                showValidationError = false
                                            }
                                        }
                                    
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
                                            .cornerRadius(10)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(height: 85)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Pay per Hour and Other Pays
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("pay_per_hour".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 4) {
                                        TextField("0.00", text: $payPerHour)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.leading)
                                            .font(.body)
                                            .focused($focusedField, equals: .payPerHour)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(showValidationError && (payPerHour.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || payPerHour.trimmingCharacters(in: .whitespacesAndNewlines).paymentAmountValue == nil) ? Color.red : Color.clear, lineWidth: 2)
                                            )
                                            .onChange(of: payPerHour) { oldValue, newValue in
                                                let filtered = newValue.filteringPaymentInput()
                                                if filtered != newValue {
                                                    payPerHour = filtered
                                                }
                                                if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && newValue.trimmingCharacters(in: .whitespacesAndNewlines).paymentAmountValue != nil {
                                                    showValidationError = false
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
                                            .cornerRadius(10)
                                            .onChange(of: otherPays) { oldValue, newValue in
                                                let filtered = newValue.filteringPaymentInput()
                                                if filtered != newValue {
                                                    otherPays = filtered
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
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Pending Confirmation Toggle
                            HStack {
                                Button(action: {
                                    if isSaved {
                                        isConfirmed.toggle()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isConfirmed ? "checkmark.square.fill" : "square")
                                            .foregroundColor(isConfirmed ? .green : .secondary)
                                            .font(.system(size: 20))
                                        Text(isConfirmed ? String(format: "confirmed_by".localized, babysitterName) : "pending_confirmation".localized)
                                            .font(.body)
                                            .foregroundColor(isConfirmed ? .green : (isSaved ? .primary : .secondary))
                                    }
                                }
                                .disabled(!isSaved)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    
                    // Comments Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "comments".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $comments)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .focused($focusedField, equals: .comments)
                                .overlay(
                                    Group {
                                        if comments.isEmpty {
                                            VStack {
                                                HStack {
                                                    Text("comments".localized)
                                                        .foregroundColor(.secondary)
                                                        .padding(.leading, 12)
                                                        .padding(.top, 8)
                                                    Spacer()
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                )
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("add_event".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(isSaved ? "close".localized : "cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSaved ? "share".localized : "save".localized) {
                        if isSaved {
                            shareEvent()
                        } else {
                            saveEvent()
                        }
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done".localized) {
                        focusedField = nil
                    }
                }
            }
            .sheet(isPresented: $showBabysitterSelection) {
                BabysitterSelectionView(
                    babysitterManager: babysitterManager,
                    onSelect: { babysitter in
                        DispatchQueue.main.async {
                            babysitterName = babysitter.name
                            if let rate = babysitter.hourlyRate {
                                payPerHour = PaymentFormat.amount(rate)
                            }
                            if let other = babysitter.otherPays {
                                otherPays = PaymentFormat.amount(other)
                            }
                            showBabysitterSelection = false
                        }
                    }
                )
            }
            .sheet(isPresented: Binding(
                get: { showShareSheet && pdfURL != nil },
                set: { showShareSheet = $0 }
            )) {
                if let url = pdfURL {
                    EventShareSheet(activityItems: [shareCaption, url])
                }
            }
        }
    }
    
    private func saveEvent() {
        let trimmedEventName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = payPerHour.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedEventName.isEmpty || trimmedName.isEmpty || trimmedRate.isEmpty || trimmedRate.paymentAmountValue == nil {
            showValidationError = true
            return
        }
        
        // Combine date and time
        let calendar = Calendar.current
        let combinedDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                             minute: calendar.component(.minute, from: startTime),
                                             second: 0,
                                             of: eventDate) ?? eventDate
        
        let event = CalendarEvent(
            userId: UUID(), // Dummy UUID for backward compatibility
            eventName: eventName.trimmingCharacters(in: .whitespacesAndNewlines),
            date: eventDate,
            startTime: combinedDateTime,
            babysitterName: trimmedName,
            payPerHour: trimmedRate.paymentAmountValue ?? 0.0,
            otherPays: otherPays.paymentAmountValue ?? 0.0,
            comments: comments.trimmingCharacters(in: .whitespacesAndNewlines),
            isConfirmed: isConfirmed,
            confirmedByName: isConfirmed ? trimmedName : nil
        )
        
        eventManager.addEvent(event)
        
        // Schedule notification if "Notify me" is checked
        if notifyMe {
            scheduleNotification(for: event, at: combinedDateTime)
        }
        
        // Mark as saved and keep modal open
        isSaved = true
        showValidationError = false
    }
    
    // Generate PDF for event
    private func generatePDF() -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "SitterPay",
            kCGPDFContextAuthor: babysitterName,
            kCGPDFContextTitle: "Event Details"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let _ = context.cgContext
            var yPosition: CGFloat = 72
            let leftMargin: CGFloat = 72
            let rightMargin: CGFloat = 72
            let _ = pageWidth - leftMargin - rightMargin
            let rowHeight: CGFloat = 30
            let _: CGFloat = 8
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.appRed
            ]
            let title = "Event Details"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 30
            
            // Event Information
            let eventInfo = [
                ("Event Name", eventName.isEmpty ? "N/A" : eventName),
                ("Date", dateFormatter.string(from: eventDate)),
                ("Start Time", timeFormatter.string(from: startTime)),
                ("Babysitter Name", babysitterName),
                ("Pay per Hour", PaymentFormat.currency(payPerHour.paymentAmountValue ?? 0.0, symbol: currencySymbol)),
                ("Other Pays", PaymentFormat.currency(otherPays.paymentAmountValue ?? 0.0, symbol: currencySymbol)),
                ("Comments", comments.isEmpty ? "N/A" : comments)
            ]
            
            for (label, value) in eventInfo {
                let labelText = "\(label):"
                let valueText = value
                
                let labelAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let valueAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.label
                ]
                
                labelText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: labelAttributes)
                valueText.draw(at: CGPoint(x: leftMargin + 150, y: yPosition), withAttributes: valueAttributes)
                yPosition += rowHeight
            }
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "SitterPay_Event_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    private func shareEvent() {
        if let url = generatePDF() {
            pdfURL = url
            // Create caption with babysitter's first name, date, and time
            let firstName = babysitterName.components(separatedBy: " ").first ?? babysitterName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: eventDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timeFormatter.dateStyle = .none
            let timeString = timeFormatter.string(from: startTime)
            
            shareCaption = String(format: "hi_name_available_babysitting".localized, firstName, dateString, timeString)
            showShareSheet = true
        }
    }
    
    private func scheduleNotification(for event: CalendarEvent, at date: Date) {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "SitterPay"
                content.body = String(format: "do_you_want_to_start_live_session_with".localized, event.babysitterName)
                content.sound = .default
                content.categoryIdentifier = "EVENT_NOTIFICATION"
                
                // Add custom actions
                let yesAction = UNNotificationAction(identifier: "YES_ACTION", title: "yes".localized, options: [.foreground])
                let noAction = UNNotificationAction(identifier: "NO_ACTION", title: "no".localized, options: [])
                let category = UNNotificationCategory(identifier: "EVENT_NOTIFICATION", actions: [yesAction, noAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                // Store event info in userInfo for later use
                content.userInfo = [
                    "eventId": event.id.uuidString,
                    "babysitterName": event.babysitterName,
                    "payPerHour": event.payPerHour,
                    "otherPays": event.otherPays
                ]
                
                // Schedule notification at the event start time
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "event_\(event.id.uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// Event Detail View
struct EventDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let event: CalendarEvent
    @ObservedObject var eventManager: CalendarEventManager
    let currencySymbol: String
    
    @State private var eventName: String
    @State private var babysitterName: String
    @State private var payPerHour: String
    @State private var otherPays: String
    @State private var comments: String
    @State private var eventDate: Date
    @State private var startTime: Date
    @State private var notifyMe: Bool = false
    @State private var isConfirmed: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var showBabysitterSelection: Bool = false
    @State private var showShareSheet: Bool = false
    @State private var pdfURL: URL?
    @State private var shareCaption: String = ""
    @State private var hasUnsavedChanges: Bool = false
    @StateObject private var babysitterManager = BabysitterManager()
    
    init(event: CalendarEvent, eventManager: CalendarEventManager, currencySymbol: String) {
        self.event = event
        self.eventManager = eventManager
        self.currencySymbol = currencySymbol
        _eventName = State(initialValue: event.eventName)
        _babysitterName = State(initialValue: event.babysitterName)
        _payPerHour = State(initialValue: PaymentFormat.amount(event.payPerHour))
        _otherPays = State(initialValue: PaymentFormat.amount(event.otherPays))
        _comments = State(initialValue: event.comments)
        _eventDate = State(initialValue: event.date)
        _startTime = State(initialValue: event.startTime ?? Date())
        _isConfirmed = State(initialValue: event.isConfirmed)
    }
    
    // Check if event is in the past
    private var isPastEvent: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let eventDay = calendar.startOfDay(for: event.date)
        return eventDay < today
    }
    
    private var canSave: Bool {
        !isPastEvent &&
        !eventName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !babysitterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !payPerHour.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        payPerHour.paymentAmountValue != nil
    }
    
    // Check if any field has changed
    private var hasChanges: Bool {
        eventName != event.eventName ||
        babysitterName != event.babysitterName ||
        payPerHour.paymentAmountValue != event.payPerHour ||
        otherPays.paymentAmountValue != event.otherPays ||
        comments != event.comments ||
        eventDate != event.date ||
        startTime != (event.startTime ?? Date()) ||
        isConfirmed != event.isConfirmed
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Event Information Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "event_information".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Event Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("event_name".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                TextField("event_name".localized, text: $eventName)
                                    .font(.body)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .disabled(isPastEvent)
                                    .foregroundColor(isPastEvent ? .secondary : .primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .onChange(of: eventName) { _, _ in hasUnsavedChanges = hasChanges }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(height: 85)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Date and Start Time
                            HStack(spacing: 16) {
                                VStack(spacing: 4) {
                                    Text("date".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $eventDate, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.blue)
                                        .disabled(isPastEvent)
                                        .onChange(of: eventDate) { _, _ in hasUnsavedChanges = hasChanges }
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider()
                                    .frame(height: 50)
                                
                                VStack(spacing: 4) {
                                    Text("start_time".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.blue)
                                        .disabled(isPastEvent)
                                        .onChange(of: startTime) { _, _ in hasUnsavedChanges = hasChanges }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Notify me checkbox
                            HStack {
                                Button(action: {
                                    if !isPastEvent {
                                        notifyMe.toggle()
                                        hasUnsavedChanges = hasChanges
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: notifyMe ? "checkmark.square.fill" : "square")
                                            .foregroundColor(notifyMe ? Color.appRed : .secondary)
                                            .font(.system(size: 20))
                                        Text("notify_me".localized)
                                            .font(.body)
                                            .foregroundColor(isPastEvent ? .secondary : .primary)
                                    }
                                }
                                .buttonStyle(.plain)
                                .disabled(isPastEvent)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Babysitter Information Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "babysitter_information".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Babysitter Name
                            VStack(alignment: .leading, spacing: 6) {
                                Text("babysitter_name".localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 8) {
                                    TextField("babysitter_name".localized, text: $babysitterName)
                                        .font(.body)
                                        .autocorrectionDisabled()
                                        .textInputAutocapitalization(.never)
                                        .disabled(isPastEvent)
                                        .foregroundColor(isPastEvent ? .secondary : .primary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 8)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .onChange(of: babysitterName) { _, _ in hasUnsavedChanges = hasChanges }
                                    
                                    Button(action: {
                                        if !isPastEvent {
                                            showBabysitterSelection = true
                                        }
                                    }) {
                                        Image("nanny")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 26, height: 26)
                                            .foregroundColor(isPastEvent ? .secondary : Color.appRed)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(isPastEvent ? Color.gray.opacity(0.1) : Color.appRed.opacity(0.1))
                                            .cornerRadius(10)
                                    }
                                    .disabled(isPastEvent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(height: 85)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Pay per Hour and Other Pays
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("pay_per_hour".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 4) {
                                        TextField("0.00", text: $payPerHour)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.leading)
                                            .font(.body)
                                            .disabled(isPastEvent)
                                            .foregroundColor(isPastEvent ? .secondary : .primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                            .onChange(of: payPerHour) { _, _ in hasUnsavedChanges = hasChanges }
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
                                            .disabled(isPastEvent)
                                            .foregroundColor(isPastEvent ? .secondary : .primary)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 8)
                                            .background(Color(.systemGray6))
                                            .cornerRadius(10)
                                            .onChange(of: otherPays) { _, _ in hasUnsavedChanges = hasChanges }
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
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Pending Confirmation Toggle
                            HStack {
                                Button(action: {
                                    if !isPastEvent {
                                        isConfirmed.toggle()
                                        hasUnsavedChanges = hasChanges
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: isConfirmed ? "checkmark.square.fill" : "square")
                                            .foregroundColor(isConfirmed ? .green : .secondary)
                                            .font(.system(size: 20))
                                        Text(isConfirmed ? String(format: "confirmed_by".localized, babysitterName) : "pending_confirmation".localized)
                                            .font(.body)
                                            .foregroundColor(isConfirmed ? .green : (isPastEvent ? .secondary : .primary))
                                    }
                                }
                                .disabled(isPastEvent)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    
                    // Comments Card
                    VStack(spacing: 0) {
                        HStack {
                            CardSectionHeader(title: "comments".localized)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $comments)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .disabled(isPastEvent)
                                .foregroundColor(isPastEvent ? .secondary : .primary)
                                .onChange(of: comments) { _, _ in hasUnsavedChanges = hasChanges }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .calcCardStyle()
                    .padding(.horizontal)
                    
                    // Delete Button
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("delete_event".localized)
                                .font(.body)
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding(.vertical, 12)
                        .calcCardStyle()
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("event_details".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(hasUnsavedChanges ? "save".localized : "share".localized) {
                        if hasUnsavedChanges {
                            saveEvent()
                        } else {
                            shareEvent()
                        }
                    }
                    .foregroundColor(hasUnsavedChanges ? (canSave ? Color.appRed : .gray) : Color.appRed)
                    .disabled(isPastEvent || (hasUnsavedChanges && !canSave))
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done".localized) {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .alert("delete_event".localized, isPresented: $showDeleteAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("delete".localized, role: .destructive) {
                    // Remove notification if event is deleted
                    let notificationId = "event_\(event.id.uuidString)"
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
                    eventManager.deleteEvent(event)
                    dismiss()
                }
            } message: {
                Text("are_you_sure_delete_event".localized)
            }
            .onAppear {
                // Check if there's an existing notification for this event
                checkForExistingNotification()
            }
            .sheet(isPresented: Binding(
                get: { showShareSheet && pdfURL != nil },
                set: { showShareSheet = $0 }
            )) {
                if let url = pdfURL {
                    EventShareSheet(activityItems: [shareCaption, url])
                }
            }
            .sheet(isPresented: $showBabysitterSelection) {
                BabysitterSelectionView(
                    babysitterManager: babysitterManager,
                    onSelect: { babysitter in
                        DispatchQueue.main.async {
                            babysitterName = babysitter.name
                            if let rate = babysitter.hourlyRate {
                                payPerHour = PaymentFormat.amount(rate)
                            }
                            if let other = babysitter.otherPays {
                                otherPays = PaymentFormat.amount(other)
                            }
                            showBabysitterSelection = false
                        }
                    }
                )
            }
            .onAppear {
                // Check if there's an existing notification for this event
                checkForExistingNotification()
            }
        }
    }
    
    private func checkForExistingNotification() {
        let notificationId = "event_\(event.id.uuidString)"
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                // Check if notification exists
                let hasNotification = requests.contains { $0.identifier == notificationId }
                notifyMe = hasNotification
            }
        }
    }
    
    // Generate PDF for event
    private func generatePDF() -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "SitterPay",
            kCGPDFContextAuthor: babysitterName,
            kCGPDFContextTitle: "Event Details"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        timeFormatter.dateStyle = .none
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let _ = context.cgContext
            var yPosition: CGFloat = 72
            let leftMargin: CGFloat = 72
            let rightMargin: CGFloat = 72
            let _ = pageWidth - leftMargin - rightMargin
            let rowHeight: CGFloat = 30
            let _: CGFloat = 8
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.appRed
            ]
            let title = "Event Details"
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 30
            
            // Event Information
            let eventInfo = [
                ("Event Name", eventName.isEmpty ? "N/A" : eventName),
                ("Date", dateFormatter.string(from: eventDate)),
                ("Start Time", timeFormatter.string(from: startTime)),
                ("Babysitter Name", babysitterName),
                ("Pay per Hour", PaymentFormat.currency(payPerHour.paymentAmountValue ?? 0.0, symbol: currencySymbol)),
                ("Other Pays", PaymentFormat.currency(otherPays.paymentAmountValue ?? 0.0, symbol: currencySymbol)),
                ("Comments", comments.isEmpty ? "N/A" : comments)
            ]
            
            for (label, value) in eventInfo {
                let labelText = "\(label):"
                let valueText = value
                
                let labelAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                    .foregroundColor: UIColor.secondaryLabel
                ]
                let valueAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.label
                ]
                
                labelText.draw(at: CGPoint(x: leftMargin, y: yPosition), withAttributes: labelAttributes)
                valueText.draw(at: CGPoint(x: leftMargin + 150, y: yPosition), withAttributes: valueAttributes)
                yPosition += rowHeight
            }
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "SitterPay_Event_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    private func shareEvent() {
        if let url = generatePDF() {
            pdfURL = url
            // Create caption with babysitter's first name, date, and time
            let firstName = babysitterName.components(separatedBy: " ").first ?? babysitterName
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            let dateString = dateFormatter.string(from: eventDate)
            
            let timeFormatter = DateFormatter()
            timeFormatter.timeStyle = .short
            timeFormatter.dateStyle = .none
            let timeString = timeFormatter.string(from: startTime)
            
            shareCaption = String(format: "hi_name_available_babysitting".localized, firstName, dateString, timeString)
            showShareSheet = true
        }
    }
    
    private func saveEvent() {
        let trimmedEventName = eventName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedName = babysitterName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRate = payPerHour.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedEventName.isEmpty == false,
              trimmedName.isEmpty == false,
              trimmedRate.isEmpty == false,
              trimmedRate.paymentAmountValue != nil else {
            return
        }
        
        // Combine date and time
        let calendar = Calendar.current
        let combinedDateTime = calendar.date(bySettingHour: calendar.component(.hour, from: startTime),
                                             minute: calendar.component(.minute, from: startTime),
                                             second: 0,
                                             of: eventDate) ?? eventDate
        
        let updatedEvent = CalendarEvent(
            id: event.id,
            userId: event.userId,
            eventName: eventName.trimmingCharacters(in: .whitespacesAndNewlines),
            date: eventDate,
            startTime: combinedDateTime,
            babysitterName: trimmedName,
            payPerHour: trimmedRate.paymentAmountValue ?? 0.0,
            otherPays: otherPays.paymentAmountValue ?? 0.0,
            comments: comments.trimmingCharacters(in: .whitespacesAndNewlines),
            isConfirmed: isConfirmed,
            confirmedByName: isConfirmed ? trimmedName : nil
        )
        
        eventManager.updateEvent(updatedEvent)
        
        // Handle notification scheduling/cancellation
        let notificationId = "event_\(event.id.uuidString)"
        
        // Remove existing notification if any
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
        
        // Schedule new notification if "Notify me" is checked
        if notifyMe {
            scheduleNotification(for: updatedEvent, at: combinedDateTime)
        }
        
        hasUnsavedChanges = false
        dismiss()
    }
    
    private func scheduleNotification(for event: CalendarEvent, at date: Date) {
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "SitterPay"
                content.body = String(format: "do_you_want_to_start_live_session_with".localized, event.babysitterName)
                content.sound = .default
                content.categoryIdentifier = "EVENT_NOTIFICATION"
                
                // Add custom actions
                let yesAction = UNNotificationAction(identifier: "YES_ACTION", title: "yes".localized, options: [.foreground])
                let noAction = UNNotificationAction(identifier: "NO_ACTION", title: "no".localized, options: [])
                let category = UNNotificationCategory(identifier: "EVENT_NOTIFICATION", actions: [yesAction, noAction], intentIdentifiers: [], options: [])
                UNUserNotificationCenter.current().setNotificationCategories([category])
                
                // Store event info in userInfo for later use
                content.userInfo = [
                    "eventId": event.id.uuidString,
                    "babysitterName": event.babysitterName,
                    "payPerHour": event.payPerHour,
                    "otherPays": event.otherPays
                ]
                
                // Schedule notification at the event start time
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "event_\(event.id.uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

// ShareSheet wrapper for UIActivityViewController
struct EventShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // Configure for iPad
        if let popover = controller.popoverPresentationController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                popover.sourceView = window
                popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        // Handle completion
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // Dismiss when done
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                dismiss()
            }
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    TemporaryView()
}

