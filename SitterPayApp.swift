//
//  SitterPayApp.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import UserNotifications

// Notification Delegate
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle notification action
        if response.actionIdentifier == "YES_ACTION" || response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            // Store babysitter info for LivePayView to pick up
            if let babysitterName = userInfo["babysitterName"] as? String {
                UserDefaults.standard.set(babysitterName, forKey: "pendingNotificationBabysitterName")
            }
            if let payPerHour = userInfo["payPerHour"] as? Double {
                UserDefaults.standard.set(payPerHour, forKey: "pendingNotificationPayPerHour")
            }
            if let otherPays = userInfo["otherPays"] as? Double {
                UserDefaults.standard.set(otherPays, forKey: "pendingNotificationOtherPays")
            }
            // Set flag to navigate to live session
            UserDefaults.standard.set(true, forKey: "shouldOpenLiveSessionFromNotification")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}

@main
struct SitterPayApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    private let notificationDelegate = NotificationDelegate()
    
    init() {
        setupAppearance()
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
    }
    
    private func setupAppearance() {
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        // Set selected and unselected item colors
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .appRed
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appRed]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.systemBackground
        navAppearance.shadowColor = .clear
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.appRed]
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.appRed]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            AppRootView(isDarkMode: $isDarkMode)
        }
    }
}

struct AppRootView: View {
    @Binding var isDarkMode: Bool
    @State private var showLogo = true
    
    var body: some View {
        Group {
            if showLogo {
                LogoView {
                    withAnimation {
                        showLogo = false
                    }
                }
            } else {
                // Show main app content
                ContentView()
                    .preferredColorScheme(isDarkMode ? .dark : .light)
                    .onChange(of: isDarkMode) { _, _ in
                        setupAppearance()
                    }
            }
        }
    }
    
    private func setupAppearance() {
        // Set tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        
        // Set selected and unselected item colors
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .appRed
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.appRed]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor.systemBackground
        navAppearance.shadowColor = .clear
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.appRed]
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.appRed]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
    }
}
