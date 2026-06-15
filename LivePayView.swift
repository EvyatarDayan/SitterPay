//
//  LivePayView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import ActivityKit

struct LivePayView: View {
    @ObservedObject var historyManager: HistoryManager
    @Binding var selectedTab: Int
    
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    
    @State private var hourlyRate: String = ""
    @State private var babysitterName: String = ""
    @State private var otherPays: String = ""
    
    private var selectedCurrency: Currency {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode }) ?? Currency.allCurrencies[0]
    }
    
    private var currencySymbol: String {
        selectedCurrency.displaySymbol
    }
    
    // Live pay states
    @State private var isLivePayRunning: Bool = false
    @State private var livePayStartTime: Date?
    @State private var livePayEndTime: Date?
    @State private var currentTime: Date = Date()
    @State private var timer: Timer?
    @State private var animationTimer: Timer?
    @State private var showValidationError: Bool = false
    @State private var showStopConfirmation: Bool = false
    @State private var showSaveSuccess: Bool = false
    @State private var dotCount: Int = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5
    @State private var previousProgress: Double = 0.0
    @State private var isResetting: Bool = false
    @State private var resetProgress: Double = 1.0
    @State private var playButtonPulseScale: CGFloat = 1.0
    @State private var playButtonPulseColor: Color = Color(white: 0.3)
    @State private var playButtonPulseTimer: Timer?
    @State private var selectTextPulseScale: CGFloat = 1.0
    @State private var selectTextPulseColor: Color = Color.secondary
    @State private var selectTextPulseTimer: Timer?
    @FocusState private var focusedField: Field?
    @State private var activity: Activity<LivePayActivityAttributes>?
    @State private var showBabysitterSelection: Bool = false
    @State private var showSelectPopup: Bool = false
    @StateObject private var babysitterManager = BabysitterManager()
    
    enum Field {
        case hourlyRate, otherPays, babysitterName
    }
    
    // Live pay calculations
    private var livePayDuration: TimeInterval {
        guard let start = livePayStartTime else { return 0 }
        let end = isLivePayRunning ? currentTime : (livePayEndTime ?? currentTime)
        return max(0, end.timeIntervalSince(start))
    }
    
    private var livePayDurationHours: Double {
        return livePayDuration / 3600.0
    }
    
    private var livePayAmount: Double {
        guard let rate = Double(hourlyRate) else { return 0.0 }
        let baseAmount = max(0, rate * livePayDurationHours)
        let otherPaysAmount = Double(otherPays) ?? 0.0
        return baseAmount + otherPaysAmount
    }
    
    private var formattedDuration: String {
        let hours = Int(livePayDurationHours)
        let minutes = Int((livePayDurationHours - Double(hours)) * 60)
        let seconds = Int(livePayDuration.truncatingRemainder(dividingBy: 60))
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private var readableDuration: String {
        let hours = Int(livePayDurationHours)
        let minutes = Int((livePayDurationHours - Double(hours)) * 60)
        
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
    
    private var summaryText: String {
        guard let start = livePayStartTime,
              let end = livePayEndTime,
              !isLivePayRunning else {
            return ""
        }
        
        let name = babysitterName.isEmpty ? "the_babysitter".localized : babysitterName
        let totalPay = String(format: "%.2f", livePayAmount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        let startTimeStr = dateFormatter.string(from: start)
        let endTimeStr = dateFormatter.string(from: end)
        
        return "\("you_need_to_pay".localized) \(name) \(currencySymbol)\(totalPay). \(name) \("worked_from".localized) \(startTimeStr) - \(endTimeStr): \(readableDuration)"
    }
    
    private var summaryTextView: Text {
        guard let start = livePayStartTime,
              let end = livePayEndTime,
              !isLivePayRunning else {
            return Text("")
        }
        
        let name = babysitterName.isEmpty ? "the_babysitter".localized : babysitterName
        let totalPay = String(format: "%.2f", livePayAmount)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        
        let startTimeStr = dateFormatter.string(from: start)
        let endTimeStr = dateFormatter.string(from: end)
        
        return Text("payment_of".localized + " ") +
               Text("\(currencySymbol)\(totalPay)")
                   .foregroundColor(.blue) +
               Text("is_due_to".localized) +
               Text(name) +
               Text("for_work_completed_from".localized) +
               Text(startTimeStr) +
               Text("to".localized) +
               Text(endTimeStr) +
               Text("total".localized) +
               Text(readableDuration)
                   .foregroundColor(.blue) +
               Text("payment_summary_end".localized)
    }
    
    private var canStartLivePay: Bool {
        return !hourlyRate.isEmpty && !babysitterName.isEmpty && Double(hourlyRate) != nil
    }
    
    // Babysitter statistics
    private var babysitterRecords: [PaymentRecord] {
        guard !babysitterName.isEmpty else { return [] }
        return historyManager.records.filter { $0.babysitterName == babysitterName }
    }
    
    private var babysitterTotalEarnings: Double {
        babysitterRecords.reduce(0) { $0 + $1.totalPay }
    }
    
    private var babysitterThisMonthCount: Int {
        let calendar = Calendar.current
        let now = Date()
        return babysitterRecords.filter { record in
            calendar.isDate(record.date, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var babysitterStatisticsText: String? {
        guard !babysitterName.isEmpty else { return nil }
        
        // Extract first name only
        let firstName = babysitterName.components(separatedBy: " ").first ?? babysitterName
        
        if babysitterRecords.isEmpty {
            return String(format: "this_is_the_first_time_for".localized, firstName)
        } else {
            // Check if we should show monthly count or total earnings
            if babysitterThisMonthCount > 0 {
                return String(format: "babysitter_worked_times_this_month".localized, firstName, babysitterThisMonthCount)
            } else {
                let formattedAmount = String(format: "%.2f", babysitterTotalEarnings)
                return String(format: "babysitter_earned_till_now".localized, firstName, currencySymbol, formattedAmount)
            }
        }
    }
    
    private var babysitterPayInfoText: String? {
        guard !babysitterName.isEmpty else { return nil }
        
        // Extract first name only
        let firstName = babysitterName.components(separatedBy: " ").first ?? babysitterName
        
        let hourlyRateValue = Double(hourlyRate) ?? 0.0
        let otherPaysValue = Double(otherPays) ?? 0.0
        
        if hourlyRateValue > 0 && otherPaysValue > 0 {
            let formattedRate = String(format: "%.2f", hourlyRateValue)
            let formattedExtras = String(format: "%.2f", otherPaysValue)
            return String(format: "babysitter_hourly_pay_with_extras".localized, firstName, currencySymbol, formattedRate, currencySymbol, formattedExtras)
        } else if hourlyRateValue > 0 {
            let formattedRate = String(format: "%.2f", hourlyRateValue)
            return String(format: "babysitter_hourly_pay".localized, firstName, currencySymbol, formattedRate)
        }
        
        return nil
    }
    
    // Progress for the circle (0.0 to 1.0, completes in 1 minute)
    private var progressValue: Double {
        guard isLivePayRunning else { return 0.0 }
        // Calculate progress based on seconds within a 60-second cycle
        let secondsInCycle = livePayDuration.truncatingRemainder(dividingBy: 120)
        return secondsInCycle / 120.0
    }
    
    // Check if we need to reset (progress went from high to low)
    private func checkForReset() {
        let current = progressValue
        // If previous was close to 1.0 and current is close to 0.0, we're resetting
        if previousProgress > 0.9 && current < 0.1 {
            isResetting = true
            resetProgress = 1.0
            // Animate the old progress fading out smoothly
            withAnimation(.easeOut(duration: 2.8)) {
                resetProgress = 0.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isResetting = false
                resetProgress = 1.0
            }
        }
        previousProgress = current
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                    Spacer()
                    
                    // Big progress circle at upper part
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color.appRed.opacity(0.2), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        // Progress circle - old progress fading out
                        if isResetting {
                            Circle()
                                .trim(from: 0, to: resetProgress)
                                .stroke(
                                    Color.appRed,
                                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
                                )
                                .frame(width: 250, height: 250)
                                .rotationEffect(.degrees(-90))
                                .opacity(resetProgress > 0 ? 1.0 : 0.0)
                                .animation(.easeOut(duration: 0.8), value: resetProgress)
                        }
                        
                        // Progress circle - new progress
                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(
                                Color.appRed,
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .opacity(isResetting ? 0.0 : 1.0)
                            .animation(.linear(duration: 0.1), value: progressValue)
                            .animation(.easeIn(duration: 0.8), value: isResetting)
                            .onChange(of: progressValue) { oldValue, newValue in
                                checkForReset()
                            }
                        
                        // Center content
                        VStack(spacing: 8) {
                            if isLivePayRunning {
                                // Show elapsed time in center
                                Text(formattedDuration)
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                
                                Text("session_is_running".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else if livePayStartTime != nil {
                                // Show final time
                                Text(formattedDuration)
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.primary)
                                
                                Text("session_ended".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                // Show placeholder
                                Text("0:00")
                                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                                    .foregroundColor(.secondary)
                                
                                Text("ready_to_start".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: geometry.size.height * 0.4)
                    
//                    Spacer()
                    
                    // Duration, Play button, and Pay in horizontal row
                    HStack(spacing: 0) {
                        // Duration
                        VStack(spacing: 4) {
                            Image("Duration")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.secondary)
                            Text((isLivePayRunning || livePayStartTime != nil) ? formattedDuration : "0:00")
                                .font(.system(size: 24, weight: .bold, design: .monospaced))
                                .foregroundColor(Color.appRed)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Play/Stop button in middle
                        Button(action: {
                            if isLivePayRunning {
                                showStopConfirmation = true
                            } else if canStartLivePay {
                                toggleLivePay()
                            } else {
                                // No babysitter selected or missing data, open selection popup
                                showSelectPopup = true
                            }
                        }) {
                            if isLivePayRunning {
                                Image("stop-button")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(Color(white: 0.3))
                            } else {
                                Image("start")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(playButtonPulseColor)
                                    .scaleEffect(playButtonPulseScale)
                            }
                        }
                        .padding(.top, 150)
                        .buttonStyle(.plain)
                        .frame(maxWidth: .infinity)
                        
                        // Pay
                        VStack(spacing: 4) {
                            Image("Payment")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.secondary)
                            HStack(spacing: 2) {
                                Text(currencySymbol)
                                    .font(.system(size: 24, weight: .bold))
                                Text((isLivePayRunning || livePayStartTime != nil) ? String(format: "%.2f", livePayAmount) : "0.00")
                                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                            }
                            .foregroundColor(Color.appRed)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    
                    // Babysitter section - fixed height to prevent layout shifts
                    VStack(spacing: 4) {
                        if !babysitterName.isEmpty {
                            Button(action: {
                                if !isLivePayRunning {
                                    showSelectPopup = true
                                }
                            }) {
                                Text(babysitterName)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            .buttonStyle(.plain)
                            .disabled(isLivePayRunning)
                            .padding(.bottom, 20)
                            
                            if let payInfoText = babysitterPayInfoText {
                                Text(payInfoText)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            if let statsText = babysitterStatisticsText {
                                Text(statsText)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        } else {
                            Button(action: {
                                showSelectPopup = true
                            }) {
                                Text("select_babysitter_to_start".localized)
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(selectTextPulseColor)
                                    .scaleEffect(selectTextPulseScale)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 100, maxHeight: 100)
                    .padding(.top, 20)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            }
            .navigationTitle("live_session".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
//            .padding(.bottom, 40)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSelectPopup = true
                    }) {
                        Image("nanny")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 26, height: 26)
                    }
                    .disabled(isLivePayRunning)
                    .foregroundColor(isLivePayRunning ? .gray : Color.appRed)
                }
            }
            .onAppear {
                startTimer()
                if isLivePayRunning {
                    startAnimationTimer()
                }
                if canStartLivePay && !isLivePayRunning {
                    startPlayButtonPulseTimer()
                } else if !isLivePayRunning {
                    startSelectTextPulseTimer()
                }
                
                // Check if we should pre-fill from notification
                checkForNotificationData()
            }
            .onDisappear {
                stopTimer()
                stopAnimationTimer()
                stopPlayButtonPulseTimer()
                stopSelectTextPulseTimer()
            }
            .onChange(of: canStartLivePay) { oldValue, newValue in
                if newValue && !isLivePayRunning {
                    stopSelectTextPulseTimer()
                    selectTextPulseScale = 1.0
                    selectTextPulseColor = Color.secondary
                    startPlayButtonPulseTimer()
                } else {
                    stopPlayButtonPulseTimer()
                    playButtonPulseScale = 1.0
                    playButtonPulseColor = Color(white: 0.3)
                    if !isLivePayRunning {
                        startSelectTextPulseTimer()
                    }
                }
            }
            .onChange(of: isLivePayRunning) { oldValue, newValue in
                if newValue {
                    stopPlayButtonPulseTimer()
                    stopSelectTextPulseTimer()
                    playButtonPulseScale = 1.0
                    playButtonPulseColor = Color(white: 0.3)
                    selectTextPulseScale = 1.0
                    selectTextPulseColor = Color.secondary
                } else {
                    if canStartLivePay {
                        startPlayButtonPulseTimer()
                    } else {
                        startSelectTextPulseTimer()
                    }
                }
            }
            .sheet(isPresented: $showSelectPopup) {
                SelectBabysitterPopupView(
                    babysitterManager: babysitterManager,
                    babysitterName: $babysitterName,
                    hourlyRate: $hourlyRate,
                    otherPays: $otherPays,
                    currencySymbol: currencySymbol,
                    onDismiss: {
                        showSelectPopup = false
                    }
                )
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
            .alert("are_you_sure".localized, isPresented: $showStopConfirmation) {
                Button("continue".localized, role: .cancel) {
                    // Just dismiss, no action needed
                }
                Button("yes".localized, role: .destructive) {
                    // Stop the session immediately
                    toggleLivePay()
                    // Show success message after stopping
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showSaveSuccess = true
                    }
                }
            } 
            .alert("pay_saved_to_history".localized, isPresented: $showSaveSuccess) {
                Button("ok".localized) {
                    clearAllFields() // Reset to default state
                }
                Button("history".localized) {
                    clearAllFields() // Reset to default state
                    selectedTab = 0 // Navigate to History tab
                }
            } 
        }
    }
    
    private func toggleLivePay() {
        if isLivePayRunning {
            // Stop the live session
            livePayEndTime = Date()
            isLivePayRunning = false
            stopAnimationTimer()
            endLiveActivity()
            
            // Automatically save to history
            saveToHistory()
        } else {
            // Start the live pay
            livePayStartTime = Date()
            livePayEndTime = nil
            isLivePayRunning = true
            dotCount = 0
            previousProgress = 0.0
            isResetting = false
            startAnimationTimer()
            startLiveActivity()
        }
    }
    
    private func startLiveActivity() {
        guard let hourlyRateValue = Double(hourlyRate) else { return }
        let otherPaysValue = Double(otherPays) ?? 0.0
        
        // Check if Live Activities are available
        guard #available(iOS 16.1, *) else {
            print("Live Activities not available on this iOS version")
            return
        }
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are disabled in system settings")
            return
        }
        
        let attributes = LivePayActivityAttributes(
            startTime: livePayStartTime ?? Date(),
            hourlyRate: hourlyRateValue,
            otherPays: otherPaysValue
        )
        
        let initialState = LivePayActivityAttributes.ContentState(
            currentPay: 0.0,
            duration: 0,
            babysitterName: babysitterName.isEmpty ? "Babysitter" : babysitterName,
            currencySymbol: currencySymbol
        )
        
        do {
            if #available(iOS 16.2, *) {
                activity = try Activity<LivePayActivityAttributes>.request(
                    attributes: attributes,
                    contentState: initialState
                )
            } else {
                activity = try Activity<LivePayActivityAttributes>.request(
                    attributes: attributes,
                    contentState: initialState,
                    pushType: nil
                )
            }
            print("✅ Live Activity started successfully")
            print("Activity ID: \(activity?.id ?? "unknown")")
        } catch {
            print("❌ Failed to start Live Activity: \(error.localizedDescription)")
            print("Error details: \(error)")
        }
    }
    
    private func updateLiveActivity() {
        guard let activity = activity else { return }
        
        let updatedState = LivePayActivityAttributes.ContentState(
            currentPay: livePayAmount,
            duration: livePayDuration,
            babysitterName: babysitterName.isEmpty ? "Babysitter" : babysitterName,
            currencySymbol: currencySymbol
        )
        
        if #available(iOS 16.1, *) {
            Task {
                await activity.update(using: updatedState)
            }
        }
    }
    
    private func endLiveActivity() {
        guard let activity = activity else { return }
        
        if #available(iOS 16.1, *) {
            let finalState = LivePayActivityAttributes.ContentState(
                currentPay: livePayAmount,
                duration: livePayDuration,
                babysitterName: babysitterName.isEmpty ? "Babysitter" : babysitterName,
                currencySymbol: currencySymbol
            )
            
            Task {
                await activity.end(using: finalState, dismissalPolicy: .immediate)
            }
        }
        
        self.activity = nil
    }
    
    private func saveToHistory() {
        guard let start = livePayStartTime,
              let end = livePayEndTime else {
            print("❌ Cannot save to history - missing data:")
            print("   Start time: \(livePayStartTime?.description ?? "nil")")
            print("   End time: \(livePayEndTime?.description ?? "nil")")
            return
        }
        
        // Allow saving even if hourly rate is empty (will default to 0)
        let hourlyRateValue = Double(hourlyRate) ?? 0.0
        let otherPaysValue = Double(otherPays) ?? 0.0
        
        // Calculate final values using the end time
        let finalDuration = end.timeIntervalSince(start)
        let finalDurationHours = max(0, finalDuration / 3600.0)
        let finalPay = (hourlyRateValue * finalDurationHours) + otherPaysValue
        
        let record = PaymentRecord(
            userId: UUID(), // Dummy UUID for backward compatibility
            babysitterName: babysitterName.isEmpty ? "Unknown" : babysitterName,
            hourlyRate: hourlyRateValue,
            otherPays: otherPaysValue,
            totalPay: finalPay,
            startTime: start,
            endTime: end,
            duration: finalDuration,
            currencyCode: selectedCurrencyCode
        )
        
        print("✅ Saving to history:")
        print("   Babysitter: \(record.babysitterName)")
        print("   Total Pay: \(record.totalPay)")
        print("   Duration: \(record.duration) seconds")
        print("   Start: \(record.startTime)")
        print("   End: \(record.endTime)")
        
        historyManager.addRecord(record)
        print("✅ Record added to history manager")
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if isLivePayRunning {
                currentTime = Date()
                // Update live activity every second (not every 0.1s)
                if Int(currentTime.timeIntervalSince1970) % 10 == 0 {
                    updateLiveActivity()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func startAnimationTimer() {
        stopAnimationTimer() // Stop any existing animation timer
        
        // Reset pulse state and start animation
        pulseScale = 1.0
        pulseOpacity = 0.5
        
        // Trigger animation
        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.3
                pulseOpacity = 0.1
            }
        }
    }
    
    private func stopAnimationTimer() {
        animationTimer?.invalidate()
        animationTimer = nil
        
        // Reset pulse state smoothly
        withAnimation(.easeOut(duration: 0.3)) {
            pulseScale = 1.0
            pulseOpacity = 0.5
        }
    }
    
    private func startPlayButtonPulseTimer() {
        stopPlayButtonPulseTimer() // Stop any existing timer
        
        // Only start if babysitter is selected and session is not running
        guard canStartLivePay && !isLivePayRunning else {
            return
        }
        
        // Reset scale and color to default
        playButtonPulseScale = 1.0
        playButtonPulseColor = Color(white: 0.3)
        
        // Create timer that pulses every 5 seconds
        playButtonPulseTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            // Only pulse if still ready to start
            guard self.canStartLivePay && !self.isLivePayRunning else {
                self.stopPlayButtonPulseTimer()
                return
            }
            
            // Pulse animation with scale and color change
            withAnimation(.easeInOut(duration: 0.6)) {
                self.playButtonPulseScale = 1.15
                self.playButtonPulseColor = Color.appRed
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.playButtonPulseScale = 1.0
                    self.playButtonPulseColor = Color(white: 0.3)
                }
            }
        }
    }
    
    private func stopPlayButtonPulseTimer() {
        playButtonPulseTimer?.invalidate()
        playButtonPulseTimer = nil
    }
    
    private func startSelectTextPulseTimer() {
        stopSelectTextPulseTimer() // Stop any existing timer
        
        // Only start if no babysitter is selected and session is not running
        guard !canStartLivePay && !isLivePayRunning else {
            return
        }
        
        // Reset scale and color to default
        selectTextPulseScale = 1.0
        selectTextPulseColor = Color.secondary
        
        // Create timer that pulses every 10 seconds
        selectTextPulseTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            // Only pulse if still no babysitter selected
            guard !self.canStartLivePay && !self.isLivePayRunning else {
                self.stopSelectTextPulseTimer()
                return
            }
            
            // Pulse animation with scale and color change
            withAnimation(.easeInOut(duration: 0.6)) {
                self.selectTextPulseScale = 1.15
                self.selectTextPulseColor = Color.appRed
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    self.selectTextPulseScale = 1.0
                    self.selectTextPulseColor = Color.secondary
                }
            }
        }
    }
    
    private func stopSelectTextPulseTimer() {
        selectTextPulseTimer?.invalidate()
        selectTextPulseTimer = nil
    }
    
    private func clearAllFields() {
        hourlyRate = ""
        babysitterName = ""
        otherPays = ""
        isLivePayRunning = false
        livePayStartTime = nil
        livePayEndTime = nil
        showValidationError = false
        focusedField = nil
    }
    
    private func checkForNotificationData() {
        // Check if we should open live session from notification
        if UserDefaults.standard.bool(forKey: "shouldOpenLiveSessionFromNotification") {
            UserDefaults.standard.set(false, forKey: "shouldOpenLiveSessionFromNotification")
            
            // Navigate to live session tab
            selectedTab = 2
            
            // Pre-fill babysitter data from notification
            if let name = UserDefaults.standard.string(forKey: "pendingNotificationBabysitterName") {
                babysitterName = name
                UserDefaults.standard.removeObject(forKey: "pendingNotificationBabysitterName")
            }
            
            if let payPerHour = UserDefaults.standard.object(forKey: "pendingNotificationPayPerHour") as? Double {
                hourlyRate = String(format: "%.2f", payPerHour)
                UserDefaults.standard.removeObject(forKey: "pendingNotificationPayPerHour")
            }
            
            if let otherPays = UserDefaults.standard.object(forKey: "pendingNotificationOtherPays") as? Double {
                self.otherPays = String(format: "%.2f", otherPays)
                UserDefaults.standard.removeObject(forKey: "pendingNotificationOtherPays")
            }
        }
    }
    
}

#Preview {
    LivePayView(historyManager: HistoryManager(), selectedTab: .constant(2))
}

