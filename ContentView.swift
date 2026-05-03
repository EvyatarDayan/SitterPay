//
//  ContentView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var historyManager = HistoryManager()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab: Int = 0
    @State private var isKeyboardVisible: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HistoryView(historyManager: historyManager)
                    .tabItem {
                        Label("history".localized, systemImage: "doc.text.fill")
                    }
                    .tag(0)
                
                        CalcView(historyManager: historyManager)
                            .tabItem {
                                Label("calculate".localized, systemImage: "hand.point.up.left.fill")
                            }
                            .tag(1)
                        
                        // Live Session view
                        LivePayView(historyManager: historyManager, selectedTab: $selectedTab)
                            .tabItem {
                                Label("live_session".localized, systemImage: "clock.fill")
                            }
                            .tag(2)
                        
                        TemporaryView()
                            .tabItem {
                                Label("calendar".localized, systemImage: "calendar")
                            }
                            .tag(3)
                        
                        SettingsView(selectedTab: $selectedTab)
                            .tabItem {
                                Label("settings".localized, systemImage: "gearshape.fill")
                            }
                            .tag(4)
            }
        }
        .onAppear {
            // Check if we should navigate to live session from notification
            if UserDefaults.standard.bool(forKey: "shouldOpenLiveSessionFromNotification") {
                selectedTab = 2
            } else {
                // Set Live Session as default view on app launch
                selectedTab = 2
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
        .id(localizationManager.currentLanguage)
    }
}

#Preview {
    ContentView()
}
