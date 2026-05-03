//
//  StatisticsView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import SwiftUI

enum TimePeriod: String, CaseIterable {
    case all = "all"
    case lastWeek = "last_week"
    case lastMonth = "last_month"
    case last3Months = "last_3_months"
}

struct StatisticsView: View {
    @ObservedObject var historyManager: HistoryManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    @State private var selectedTimePeriod: TimePeriod = .all
    @State private var refreshId: UUID = UUID()
    @StateObject private var eventManager = CalendarEventManager()
    @StateObject private var babysitterManager = BabysitterManager()
    
    private var currencySymbol: String {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode })?.displaySymbol ?? "$"
    }
    
    // Filter records based on selected time period
    private var filteredRecords: [PaymentRecord] {
        let allRecords = historyManager.records
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimePeriod {
        case .all:
            return allRecords
        case .lastWeek:
            guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
                return allRecords
            }
            return allRecords.filter { $0.date >= oneWeekAgo }
        case .lastMonth:
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
                return allRecords
            }
            return allRecords.filter { $0.date >= oneMonthAgo }
        case .last3Months:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now) else {
                return allRecords
            }
            return allRecords.filter { $0.date >= threeMonthsAgo }
        }
    }
    
    // Calculate statistics from filtered records
    private var statistics: StatisticsData {
        let records = filteredRecords
        
        guard !records.isEmpty else {
            return StatisticsData(
                totalPayments: 0,
                totalHours: 0,
                averagePayPerHour: 0,
                payByBabysitter: [:]
            )
        }
        
        let totalPayments = records.reduce(0) { $0 + $1.totalPay }
        let totalHours = records.reduce(0) { $0 + ($1.duration / 3600) }
        let averagePayPerHour = totalHours > 0 ? totalPayments / totalHours : 0
        
        // Group by babysitter
        var payByBabysitter: [String: Double] = [:]
        for record in records {
            payByBabysitter[record.babysitterName, default: 0] += record.totalPay
        }
        
        return StatisticsData(
            totalPayments: totalPayments,
            totalHours: totalHours,
            averagePayPerHour: averagePayPerHour,
            payByBabysitter: payByBabysitter
        )
    }
    
    // Get upcoming events count for next 30 days
    private var upcomingEventsCount: Int {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        guard let thirtyDaysFromNow = calendar.date(byAdding: .day, value: 30, to: today) else {
            return 0
        }
        
        return eventManager.events.filter { event in
            let eventDate = calendar.startOfDay(for: event.date)
            return eventDate >= today && eventDate <= thirtyDaysFromNow
        }.count
    }
    
    // Get babysitters count
    private var babysittersCount: Int {
        babysitterManager.babysitters.count
    }
    
    // Colors for pie chart
    private let chartColors: [Color] = [
        .blue, .green, .orange, .purple, .pink, .red, .yellow, .cyan, .mint, .indigo
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                // Filter buttons
                if !historyManager.records.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TimePeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedTimePeriod = period
                                }) {
                                    Text(period.rawValue.localized)
                                        .font(.subheadline)
                                        .foregroundColor(selectedTimePeriod == period ? .white : Color.appRed)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedTimePeriod == period ? Color.appRed : Color.appRed.opacity(0.1))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    .background(Color(.systemGroupedBackground))
                }
                
                VStack(spacing: 24) {
                    if historyManager.records.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text("no_statistics_available".localized)
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Summary Cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "total_payments".localized,
                                    value: String(format: "\(currencySymbol)%.2f", statistics.totalPayments),
                                    icon: nil,
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "total_hours".localized,
                                    value: String(format: "%.1f", statistics.totalHours),
                                    icon: nil,
                                    color: .blue
                                )
                            }
                            
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "upcoming_events".localized,
                                    value: "\(upcomingEventsCount)",
                                    icon: nil,
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "babysitters".localized,
                                    value: "\(babysittersCount)",
                                    icon: nil,
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Pie Chart Section
                        if !statistics.payByBabysitter.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("pay_by_babysitter".localized)
                                    .font(.headline)
                                
                                PieChartView(
                                    data: statistics.payByBabysitter,
                                    colors: chartColors,
                                    currencySymbol: currencySymbol
                                )
                                .frame(height: 225)
                                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                                
                                // Legend with internal scroll
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(Array(statistics.payByBabysitter.sorted(by: { $0.value > $1.value }).enumerated()), id: \.element.key) { index, item in
                                            let (name, amount) = item
                                            HStack {
                                                Circle()
                                                    .fill(chartColors[index % chartColors.count])
                                                    .frame(width: 12, height: 12)
                                                
                                                Text(name)
                                                    .font(.subheadline)
                                                
                                                Spacer()
                                                
                                                Text(String(format: "\(currencySymbol)%.2f", amount))
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                            }
                                        }
                                    }
                                }
                                .frame(maxHeight: 200)
                            }
                            .padding()
                            .background(
                                Color(uiColor: UIColor { traitCollection in
                                    traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                })
                            )
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            }
            .navigationTitle("statistics".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("close".localized) {
                        dismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
            }
            .id("\(localizationManager.currentLanguage)-\(refreshId)")
            .onAppear {
                // Reload records to ensure we have the latest data from history
                // This includes all records saved via calculate view or live session
                historyManager.loadRecords()
            }
            .onChange(of: selectedCurrencyCode) { oldValue, newValue in
                // Reload records when currency changes to reflect updated currency codes
                historyManager.loadRecords()
            }
        }
    }
}

struct StatisticsData {
    let totalPayments: Double
    let totalHours: Double
    let averagePayPerHour: Double
    let payByBabysitter: [String: Double]
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
    }
}

struct PieChartView: View {
    let data: [String: Double]
    let colors: [Color]
    let currencySymbol: String
    
    @State private var sliceOpacities: [Double] = []
    @State private var showInnerCircle: Bool = false
    
    private var total: Double {
        data.values.reduce(0, +)
    }
    
    private var sortedData: [(String, Double)] {
        data.sorted(by: { $0.value > $1.value })
    }
    
    var body: some View {
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            let radius = min(geometry.size.width, geometry.size.height) / 2 - 10
            
            ZStack {
                // Draw pie slices with fade-in animation (one after another)
                ForEach(Array(sortedData.enumerated()), id: \.element.0) { index, item in
                    let (name, value) = item
                    let percentage = value / total
                    let startAngle = sortedData.prefix(index).reduce(0) { $0 + ($1.1 / total) * 360 }
                    let endAngle = startAngle + (percentage * 360)
                    
                    let opacity = index < sliceOpacities.count ? sliceOpacities[index] : 0.0
                    
                    PieSlice(
                        center: center,
                        radius: radius,
                        startAngle: Angle(degrees: startAngle - 90),
                        endAngle: Angle(degrees: endAngle - 90),
                        color: colors[index % colors.count],
                        animationProgress: 1.0 // Always fully drawn
                    )
                    .opacity(opacity)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                // Center circle with total - much wider inner circle
                if showInnerCircle {
                    Circle()
                        .fill(Color(uiColor: UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.white
                        }))
                        .frame(width: radius * 1, height: radius * 1)
                        .overlay(
                            VStack(spacing: 6) {
                                Text("Total")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Text(String(format: "\(currencySymbol)%.2f", total))
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .padding(.horizontal, 10)
                            .multilineTextAlignment(.center)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .position(center)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onAppear {
            startAnimation()
        }
        .onChange(of: data) { _, _ in
            // Reset and re-animate when data changes
            sliceOpacities = []
            showInnerCircle = false
            startAnimation()
        }
    }
    
    private func startAnimation() {
        let sliceCount = sortedData.count
        sliceOpacities = Array(repeating: 0.0, count: sliceCount)
        showInnerCircle = false
        
        // Show inner circle first
        withAnimation(.easeInOut(duration: 0.3)) {
            showInnerCircle = true
        }
        
        // Animate each slice fade-in one after another (faster)
        for index in 0..<sliceCount {
            let delay = Double(index) * 0.1 + 0.2 // 0.1 seconds between each slice, start after inner circle
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeIn(duration: 0.3)) {
                    if index < sliceOpacities.count {
                        sliceOpacities[index] = 1.0
                    }
                }
            }
        }
    }
}

struct PieSlice: View {
    let center: CGPoint
    let radius: CGFloat
    let startAngle: Angle
    let endAngle: Angle
    let color: Color
    var animationProgress: Double = 1.0
    
    private var animatedEndAngle: Angle {
        let angleRange = endAngle.degrees - startAngle.degrees
        return Angle(degrees: startAngle.degrees + (angleRange * animationProgress))
    }
    
    var body: some View {
        ZStack {
            // Main slice
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: animatedEndAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .fill(color)
            
            // White border between slices (matching BillTracker style)
            Path { path in
                path.move(to: center)
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: animatedEndAngle,
                    clockwise: false
                )
                path.closeSubpath()
            }
            .stroke(Color.white, lineWidth: 1.0)
        }
    }
}

#Preview {
    StatisticsView(historyManager: HistoryManager())
}

