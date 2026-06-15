//
//  PaymentDetailView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import PDFKit

struct PaymentDetailView: View {
    let record: PaymentRecord
    @Environment(\.dismiss) var dismiss
    @ObservedObject var historyManager: HistoryManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var isPaid: Bool
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var selectedTip: Double?
    @State private var hasUnsavedChanges: Bool = false
    @State private var currentRecord: PaymentRecord
    @State private var selectedEvent: CalendarEvent?
    @State private var showEventSelection: Bool = false
    @StateObject private var eventManager = CalendarEventManager()
    
    // Helper function to get currency symbol from currency code
    private func currencySymbol(for code: String) -> String {
        Currency.allCurrencies.first(where: { $0.code == code })?.displaySymbol ?? "$"
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
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
    
    // Generate PDF from payment record
    private func generatePDF() -> URL? {
        // Use currentRecord (which may have been updated) and selectedTip for accurate data
        let recordToUse = currentRecord
        let tipToUse = selectedTip ?? recordToUse.tipPercentage
        let totalPayToUse = calculatedTotalPay
        
        let pdfMetaData = [
            kCGPDFContextCreator: "SitterPay",
            kCGPDFContextAuthor: recordToUse.babysitterName,
            kCGPDFContextTitle: "Payment Details"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let cgContext = context.cgContext
            var yPosition: CGFloat = 72
            let leftMargin: CGFloat = 72
            let rightMargin: CGFloat = 72
            let tableWidth = pageWidth - leftMargin - rightMargin
            let rowHeight: CGFloat = 30
            let cellPadding: CGFloat = 8
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.appRed
            ]
            let title = "payment_details".localized
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 40
            
            // Work Information Section Table
            let workInfoTitle = "work_information".localized
            yPosition = drawSectionTitle(title: workInfoTitle, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Babysitter Name row
            yPosition = drawTableRow(label: "babysitter_name".localized, value: recordToUse.babysitterName, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Date row
            let dateValue = dateFormatter.string(from: recordToUse.date)
            yPosition = drawTableRow(label: "date".localized, value: dateValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            yPosition += 20
            
            // Time Information Section Table
            let timeInfoTitle = "time_information".localized
            yPosition = drawSectionTitle(title: timeInfoTitle, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Time Range row
            let timeRangeValue = "\(timeFormatter.string(from: recordToUse.startTime)) - \(timeFormatter.string(from: recordToUse.endTime))"
            yPosition = drawTableRow(label: "time_range".localized, value: timeRangeValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Duration row
            let durationValue = formatDuration(recordToUse.duration)
            yPosition = drawTableRow(label: "duration".localized, value: durationValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            yPosition += 20
            
            // Payment Details Section Table
            let paymentTitle = "payment_details".localized
            yPosition = drawSectionTitle(title: paymentTitle, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Pay per Hour row
            let payPerHourValue = "\(currencySymbol(for: recordToUse.currencyCode))\(String(format: "%.2f", recordToUse.hourlyRate))"
            yPosition = drawTableRow(label: "pay_per_hour".localized, value: payPerHourValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Other Pays row
            let otherPaysValue = "\(currencySymbol(for: recordToUse.currencyCode))\(String(format: "%.2f", recordToUse.otherPays))"
            yPosition = drawTableRow(label: "other_pays".localized, value: otherPaysValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            
            // Tip row (if tip is selected)
            if let tip = tipToUse {
                let tipValue = "\(String(format: "%.0f", tip))%"
                yPosition = drawTableRow(label: "tip".localized, value: tipValue, yPosition: yPosition, leftMargin: leftMargin, tableWidth: tableWidth, rowHeight: rowHeight, cellPadding: cellPadding, cgContext: cgContext)
            }
            
            yPosition += 30
            
            // Total Pay - Bigger and Centered
            let totalPayValue = "\(currencySymbol(for: recordToUse.currencyCode))\(String(format: "%.2f", totalPayToUse))"
            let totalAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 32),
                .foregroundColor: UIColor.systemBlue
            ]
            let totalLabel = "total_pay".localized
            let totalLabelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 20),
                .foregroundColor: UIColor.label
            ]
            let totalLabelSize = totalLabel.size(withAttributes: totalLabelAttributes)
            let totalValueSize = totalPayValue.size(withAttributes: totalAttributes)
            let totalY = yPosition + 20
            totalLabel.draw(at: CGPoint(x: (pageWidth - totalLabelSize.width) / 2, y: totalY), withAttributes: totalLabelAttributes)
            let totalValueY = totalY + totalLabelSize.height + 10
            totalPayValue.draw(at: CGPoint(x: (pageWidth - totalValueSize.width) / 2, y: totalValueY), withAttributes: totalAttributes)
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "SitterPay_\(dateFormatter.string(from: recordToUse.date)).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error creating PDF: \(error)")
            return nil
        }
    }
    
    private func drawSectionTitle(title: String, yPosition: CGFloat, leftMargin: CGFloat, tableWidth: CGFloat, rowHeight: CGFloat, cellPadding: CGFloat, cgContext: CGContext) -> CGFloat {
        let sectionTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16),
            .foregroundColor: UIColor.label
        ]
        
        let titleSize = title.size(withAttributes: sectionTitleAttributes)
        let titleRect = CGRect(x: leftMargin, y: yPosition, width: tableWidth, height: rowHeight)
        
        // Draw light background
        UIColor.systemGray6.setFill()
        cgContext.fill(titleRect)
        
        // Draw title text
        title.draw(at: CGPoint(x: leftMargin + cellPadding, y: yPosition + (rowHeight - titleSize.height) / 2), withAttributes: sectionTitleAttributes)
        
        // Draw border
        cgContext.setStrokeColor(UIColor.separator.cgColor)
        cgContext.setLineWidth(1.0)
        cgContext.stroke(titleRect)
        
        return yPosition + rowHeight
    }
    
    private func drawTableRow(label: String, value: String, yPosition: CGFloat, leftMargin: CGFloat, tableWidth: CGFloat, rowHeight: CGFloat, cellPadding: CGFloat, cgContext: CGContext) -> CGFloat {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.secondaryLabel
        ]
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.label
        ]
        
        // Draw row border
        let rowRect = CGRect(x: leftMargin, y: yPosition, width: tableWidth, height: rowHeight)
        cgContext.setStrokeColor(UIColor.separator.cgColor)
        cgContext.setLineWidth(1.0)
        cgContext.stroke(rowRect)
        
        // Draw label
        let labelSize = label.size(withAttributes: labelAttributes)
        label.draw(at: CGPoint(x: leftMargin + cellPadding, y: yPosition + (rowHeight - labelSize.height) / 2), withAttributes: labelAttributes)
        
        // Draw value
        let valueSize = value.size(withAttributes: valueAttributes)
        value.draw(at: CGPoint(x: leftMargin + tableWidth - cellPadding - valueSize.width, y: yPosition + (rowHeight - valueSize.height) / 2), withAttributes: valueAttributes)
        
        return yPosition + rowHeight
    }
    
    init(record: PaymentRecord, historyManager: HistoryManager) {
        self.record = record
        self.historyManager = historyManager
        _isPaid = State(initialValue: record.isPaid)
        _selectedTip = State(initialValue: record.tipPercentage)
        _currentRecord = State(initialValue: record)
        _selectedEvent = State(initialValue: nil)
    }
    
    // Calculate total pay with selected tip (for display)
    private var calculatedTotalPay: Double {
        // Get base pay (without tip)
        var basePay = currentRecord.totalPay
        if let oldTip = currentRecord.tipPercentage {
            // Remove old tip: basePay = totalPay / (1 + tip/100)
            basePay = currentRecord.totalPay / (1 + oldTip / 100.0)
        }
        
        // Add selected tip if any
        if let tip = selectedTip {
            return basePay * (1 + tip / 100.0)
        } else {
            return basePay
        }
    }
    
    private func saveTip() {
        if hasUnsavedChanges {
            // Save tip
            historyManager.updateTip(for: currentRecord, tipPercentage: selectedTip)
            // Save event if changed
            if let event = selectedEvent {
                historyManager.updateEvent(for: currentRecord, eventId: event.id)
            } else {
                historyManager.updateEvent(for: currentRecord, eventId: nil)
            }
            // Immediately update currentRecord to reflect the saved changes
            if let updatedRecord = historyManager.records.first(where: { $0.id == currentRecord.id }) {
                currentRecord = updatedRecord
            }
            // Also update selectedTip to match the saved record
            selectedTip = currentRecord.tipPercentage
            // Reload selected event from updated record
            if let eventId = currentRecord.eventId {
                selectedEvent = eventManager.events.first(where: { $0.id == eventId })
            } else {
                selectedEvent = nil
            }
            hasUnsavedChanges = false
        } else {
            dismiss()
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                VStack(spacing: 20) {
                    // Header Card - Babysitter Name and Event
                    VStack(spacing: 16) {
                        VStack(spacing: 4) {
                            Text("babysitter_name".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(record.babysitterName)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        
                        Divider()
                        
                        // Event field
                        VStack(spacing: 4) {
                            Text("event".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(selectedEvent?.eventName ?? "")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedEvent == nil ? .secondary : .primary)
                            Button(action: {
                                showEventSelection = true
                            }) {
                                Text("select_event".localized)
                                    .font(.caption)
                                    .foregroundColor(Color.appRed)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.appRed.opacity(0.1))
                                    .cornerRadius(6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 16)
                            .background(
                                Color(uiColor: UIColor { traitCollection in
                                    traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                })
                            )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Time Details Card
                    VStack(spacing: 0) {
                        HStack {
                            Text("time_information".localized)
                                .font(.headline)
                                .foregroundColor(Color.appRed)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Date
                            HStack {
                                Text("date".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(dateFormatter.string(from: record.date))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Time Range
                            HStack {
                                Text("time_range".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(timeFormatter.string(from: record.startTime)) - \(timeFormatter.string(from: record.endTime))")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Duration
                            HStack {
                                Text("duration".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(formatDuration(record.duration))
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                            .background(
                                Color(uiColor: UIColor { traitCollection in
                                    traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                })
                            )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Payment Details Card
                    VStack(spacing: 0) {
                        HStack {
                            Text("payment_details".localized)
                                .font(.headline)
                                .foregroundColor(Color.appRed)
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        VStack(spacing: 0) {
                            // Pay per Hour
                            HStack {
                                Text("pay_per_hour".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(currencySymbol(for: record.currencyCode))\(String(format: "%.2f", record.hourlyRate))")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Other Pays
                            HStack {
                                Text("other_pays".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("\(currencySymbol(for: record.currencyCode))\(String(format: "%.2f", record.otherPays))")
                                    .font(.body)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Tip Selection
                            HStack {
                                Text("tip".localized)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                Spacer()
                                
                                HStack(spacing: 8) {
                                    Button(action: {
                                        if selectedTip == 5 {
                                            selectedTip = nil
                                        } else {
                                            selectedTip = 5
                                        }
                                        hasUnsavedChanges = true
                                    }) {
                                        Text("5%")
                                            .font(.caption)
                                            .foregroundColor(selectedTip == 5 ? .white : Color.appRed)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTip == 5 ? Color.appRed : Color.appRed.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                    
                                    Button(action: {
                                        if selectedTip == 10 {
                                            selectedTip = nil
                                        } else {
                                            selectedTip = 10
                                        }
                                        hasUnsavedChanges = true
                                    }) {
                                        Text("10%")
                                            .font(.caption)
                                            .foregroundColor(selectedTip == 10 ? .white : Color.appRed)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTip == 10 ? Color.appRed : Color.appRed.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                    
                                    Button(action: {
                                        if selectedTip == 20 {
                                            selectedTip = nil
                                        } else {
                                            selectedTip = 20
                                        }
                                        hasUnsavedChanges = true
                                    }) {
                                        Text("20%")
                                            .font(.caption)
                                            .foregroundColor(selectedTip == 20 ? .white : Color.appRed)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(selectedTip == 20 ? Color.appRed : Color.appRed.opacity(0.1))
                                            .cornerRadius(6)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            
                            Divider()
                                .padding(.leading, 16)
                            
                            // Total Pay
                            HStack {
                                Text("total_pay".localized)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(currencySymbol(for: currentRecord.currencyCode))\(String(format: "%.2f", calculatedTotalPay))")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color.appRed)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                            .background(
                                Color(uiColor: UIColor { traitCollection in
                                    traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                })
                            )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    // Payment Status Toggle
                    HStack(spacing: 12) {
                        Circle()
                            .fill((isPaid ? Color.green : Color.appRed).opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Image(systemName: isPaid ? "checkmark.circle.fill" : "clock.fill")
                                    .foregroundColor(isPaid ? .green : Color.appRed)
                                    .font(.system(size: 16))
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("payment_status".localized)
                                .font(.body)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                            Text(isPaid ? "paid".localized : "pending".localized)
                                .font(.caption)
                                .foregroundColor(isPaid ? .green : .blue)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { isPaid },
                            set: { newValue in
                                historyManager.updatePaidStatus(for: record, isPaid: newValue)
                                isPaid = newValue
                            }
                        ))
                        .labelsHidden()
                        .scaleEffect(0.75)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Color(uiColor: UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                        })
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                }
            }
            .navigationTitle("payment_details".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("export".localized) {
                        if let url = generatePDF() {
                            pdfURL = url
                            showShareSheet = true
                        }
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(hasUnsavedChanges ? "save".localized : "done".localized) {
                        saveTip()
                    }
                    .foregroundColor(Color.appRed)
                }
            }
            .sheet(isPresented: Binding(
                get: { showShareSheet && pdfURL != nil },
                set: { showShareSheet = $0 }
            )) {
                if let url = pdfURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showEventSelection) {
                EventSelectionView(
                    eventManager: eventManager,
                    selectedDate: record.date,
                    selectedEvent: Binding(
                        get: { selectedEvent },
                        set: { newEvent in
                            selectedEvent = newEvent
                            hasUnsavedChanges = true
                        }
                    )
                )
            }
            .onAppear {
                // Load event if eventId exists
                if let eventId = record.eventId {
                    selectedEvent = eventManager.events.first(where: { $0.id == eventId })
                }
            }
        }
    }
    
    // Get events for the record's date
    private var eventsForDate: [CalendarEvent] {
        eventManager.eventsForDate(record.date)
    }
}

// Event Selection View
struct EventSelectionView: View {
    @ObservedObject var eventManager: CalendarEventManager
    let selectedDate: Date
    @Binding var selectedEvent: CalendarEvent?
    @Environment(\.dismiss) var dismiss
    
    private var eventsForDate: [CalendarEvent] {
        eventManager.eventsForDate(selectedDate)
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(eventsForDate) { event in
                    Button(action: {
                        selectedEvent = event
                        dismiss()
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.eventName)
                                .font(.headline)
                                .foregroundColor(.primary)
                            if let startTime = event.startTime {
                                Text(timeFormatter.string(from: startTime))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("select_event".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
            }
        }
    }
}

// ShareSheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
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
        // No update needed
    }
}

