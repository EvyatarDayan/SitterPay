//
//  HistoryView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import PDFKit

struct HistoryView: View {
    @ObservedObject var historyManager: HistoryManager
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    @State private var selectedRecord: PaymentRecord?
    @State private var showShareSheet = false
    @State private var pdfURL: URL?
    @State private var selectedBabysitter: String? = nil
    @State private var refreshId: UUID = UUID()
    
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
    
    // Get unique babysitter names from records
    private var uniqueBabysitters: [String] {
        Array(Set(historyManager.records.map { $0.babysitterName })).sorted()
    }
    
    // Sort records by date (newest first) and filter by selected babysitter
    private var sortedRecords: [PaymentRecord] {
        var records = historyManager.records
        
        // Filter by selected babysitter if any
        if let selectedBabysitter = selectedBabysitter {
            records = records.filter { $0.babysitterName == selectedBabysitter }
        }
        
        return records.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                Group {
                    if historyManager.records.isEmpty {
                        VStack {
                            Spacer()
                            Text("no_history_saved_yet".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                    VStack(spacing: 0) {
                        // Filter buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                // "All" button
                                Button(action: {
                                    selectedBabysitter = nil
                                }) {
                                    Text("all".localized)
                                        .font(.subheadline)
                                        .foregroundColor(selectedBabysitter == nil ? .white : Color.appRed)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedBabysitter == nil ? Color.appRed : Color.appRed.opacity(0.1))
                                        .cornerRadius(20)
                                }
                                
                                // Babysitter filter buttons
                                ForEach(uniqueBabysitters, id: \.self) { babysitter in
                                    Button(action: {
                                        selectedBabysitter = (selectedBabysitter == babysitter) ? nil : babysitter
                                    }) {
                                        Text(babysitter)
                                            .font(.subheadline)
                                            .foregroundColor(selectedBabysitter == babysitter ? .white : Color.appRed)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(selectedBabysitter == babysitter ? Color.appRed : Color.appRed.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                        }
                        .background(Color(.systemGroupedBackground))
                        
                        // Records list
                        List {
                            ForEach(sortedRecords) { record in
                                recordRow(record: record)
                            }
                            .onDelete { indexSet in
                                for index in indexSet {
                                    historyManager.deleteRecord(sortedRecords[index])
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            }
            .navigationTitle("history".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                if !historyManager.records.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("export".localized) {
                            exportAllToPDF()
                        }
                        .foregroundColor(Color.appRed)
                    }
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
            .sheet(item: $selectedRecord) { record in
                PaymentDetailView(record: record, historyManager: historyManager)
            }
            .onAppear {
                // Reload records when view appears
                historyManager.loadRecords()
            }
            .onChange(of: selectedCurrencyCode) { oldValue, newValue in
                // Reload records when currency changes to reflect updated currency codes
                historyManager.loadRecords()
                // Force view refresh
                refreshId = UUID()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CurrencyDidChange"))) { _ in
                // Reload records when currency change notification is received
                historyManager.loadRecords()
                // Force view refresh
                refreshId = UUID()
            }
            .id(refreshId)
        }
    }
    
    @ViewBuilder
    private func recordRow(record: PaymentRecord) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(record.babysitterName)
                    .font(.headline)
                
                Text("\(dateFormatter.string(from: record.date)) • \(DurationFormat.compact(record.duration))")
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                                    Text(PaymentFormat.currency(record.totalPay, symbol: currencySymbol(for: record.currencyCode)))
                                        .font(.headline)
                                        .foregroundColor(Color.appRed)
                
                // Status label
                                    Text(record.isPaid ? "paid".localized : "pending".localized)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(record.isPaid ? .green : Color.appRed)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(record.isPaid ? Color.green.opacity(0.2) : Color.appRed.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .calcCardStyle()
        .listRowBackground(Color(.systemGroupedBackground))
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets.cardListRow)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedRecord = record
        }
    }
    
    private func exportAllToPDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "SitterPay",
            kCGPDFContextAuthor: "SitterPay",
            kCGPDFContextTitle: "Payment History Summary"
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
            let title = "payment_history_summary".localized
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width) / 2, y: yPosition), withAttributes: titleAttributes)
            yPosition += titleSize.height + 20
            
            // Summary info
            let summaryText = String(format: "total_records".localized, sortedRecords.count)
            let summaryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.secondaryLabel
            ]
            let summarySize = summaryText.size(withAttributes: summaryAttributes)
            summaryText.draw(at: CGPoint(x: (pageWidth - summarySize.width) / 2, y: yPosition), withAttributes: summaryAttributes)
            yPosition += summarySize.height + 30
            
            // Table header
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 14),
                .foregroundColor: UIColor.label
            ]
            
            // Draw header columns
            let columns = ["name".localized, "date".localized, "duration".localized, "total_pay".localized, "status".localized]
            let columnWidth = tableWidth / CGFloat(columns.count)
            
            // Calculate the maximum height needed for header
            var maxHeaderHeight: CGFloat = rowHeight
            let availableCellWidth = columnWidth - (cellPadding * 2)
            
            for column in columns {
                let boundingRect = (column as NSString).boundingRect(
                    with: CGSize(width: availableCellWidth, height: CGFloat.greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: headerAttributes,
                    context: nil
                )
                let cellHeight = max(boundingRect.height + (cellPadding * 2), rowHeight)
                maxHeaderHeight = max(maxHeaderHeight, cellHeight)
            }
            
            let headerRect = CGRect(x: leftMargin, y: yPosition, width: tableWidth, height: maxHeaderHeight)
            UIColor.systemGray6.setFill()
            cgContext.fill(headerRect)
            
            // Draw header columns with multi-line support
            for (index, column) in columns.enumerated() {
                let xPosition = leftMargin + CGFloat(index) * columnWidth
                let cellRect = CGRect(
                    x: xPosition + cellPadding,
                    y: yPosition + cellPadding,
                    width: columnWidth - (cellPadding * 2),
                    height: maxHeaderHeight - (cellPadding * 2)
                )
                
                // Draw text with wrapping
                (column as NSString).draw(
                    in: cellRect,
                    withAttributes: headerAttributes
                )
                
                // Draw vertical line
                if index > 0 {
                    cgContext.setStrokeColor(UIColor.separator.cgColor)
                    cgContext.setLineWidth(1.0)
                    cgContext.move(to: CGPoint(x: xPosition, y: yPosition))
                    cgContext.addLine(to: CGPoint(x: xPosition, y: yPosition + maxHeaderHeight))
                    cgContext.strokePath()
                }
            }
            
            // Draw header border
            cgContext.setStrokeColor(UIColor.separator.cgColor)
            cgContext.setLineWidth(1.0)
            cgContext.stroke(headerRect)
            yPosition += maxHeaderHeight
            
            // Draw records
            let recordAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.label
            ]
            
            for record in sortedRecords {
                // Prepare row data
                let dateText = dateFormatter.string(from: record.date)
                let durationText = DurationFormat.compact(record.duration)
                let totalPayText = PaymentFormat.currency(record.totalPay, symbol: currencySymbol(for: record.currencyCode))
                let statusText = record.isPaid ? "paid".localized : "pending".localized
                
                let rowData = [record.babysitterName, dateText, durationText, totalPayText, statusText]
                
                // Calculate the maximum height needed for this row
                var maxCellHeight: CGFloat = rowHeight
                let availableCellWidth = columnWidth - (cellPadding * 2)
                
                for data in rowData {
                    let boundingRect = (data as NSString).boundingRect(
                        with: CGSize(width: availableCellWidth, height: CGFloat.greatestFiniteMagnitude),
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        attributes: recordAttributes,
                        context: nil
                    )
                    let cellHeight = max(boundingRect.height + (cellPadding * 2), rowHeight)
                    maxCellHeight = max(maxCellHeight, cellHeight)
                }
                
                // Check if we need a new page
                if yPosition + maxCellHeight > pageHeight - 72 {
                    context.beginPage()
                    yPosition = 72
                }
                
                let rowRect = CGRect(x: leftMargin, y: yPosition, width: tableWidth, height: maxCellHeight)
                
                // Draw row data with multi-line support
                for (index, data) in rowData.enumerated() {
                    let xPosition = leftMargin + CGFloat(index) * columnWidth
                    let cellRect = CGRect(
                        x: xPosition + cellPadding,
                        y: yPosition + cellPadding,
                        width: columnWidth - (cellPadding * 2),
                        height: maxCellHeight - (cellPadding * 2)
                    )
                    
                    // Draw text with wrapping
                    (data as NSString).draw(
                        in: cellRect,
                        withAttributes: recordAttributes
                    )
                    
                    // Draw vertical line
                    if index > 0 {
                        cgContext.setStrokeColor(UIColor.separator.cgColor)
                        cgContext.setLineWidth(1.0)
                        cgContext.move(to: CGPoint(x: xPosition, y: yPosition))
                        cgContext.addLine(to: CGPoint(x: xPosition, y: yPosition + maxCellHeight))
                        cgContext.strokePath()
                    }
                }
                
                // Draw row border
                cgContext.setStrokeColor(UIColor.separator.cgColor)
                cgContext.setLineWidth(1.0)
                cgContext.stroke(rowRect)
                
                yPosition += maxCellHeight
            }
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "SitterPay_History_\(Date().timeIntervalSince1970).pdf"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            pdfURL = fileURL
            showShareSheet = true
        } catch {
            print("Error creating PDF: \(error)")
        }
    }
}

#Preview {
    HistoryView(historyManager: HistoryManager())
}

