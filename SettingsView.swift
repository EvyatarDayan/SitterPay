//
//  SettingsView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("selectedCurrencyCode") private var selectedCurrencyCode: String = "USD"
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "English"
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedTab: Int
    @State private var showCurrencySelection: Bool = false
    @State private var showLanguageSelection: Bool = false
    @State private var showTermsPrivacy: Bool = false
    @State private var showHelpSupport: Bool = false
    @State private var showAbout: Bool = false
    @State private var showBabysitters: Bool = false
    @State private var showStatistics: Bool = false
    @State private var showClearHistoryAlert: Bool = false
    @StateObject private var historyManager = HistoryManager()

    private var selectedCurrency: Currency {
        Currency.allCurrencies.first(where: { $0.code == selectedCurrencyCode }) ?? Currency.allCurrencies[0]
    }
    
    private func flagForLanguage(_ language: String) -> String {
        let languageFlags: [String: String] = [
            "English": "🇬🇧",
            "German": "🇩🇪",
            "French": "🇫🇷",
            "Swedish": "🇸🇪",
            "Spanish": "🇪🇸"
        ]
        return languageFlags[language] ?? "🇬🇧"
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 16) {
                    // MY BABYSITTERS Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("my_babysitters".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showBabysitters = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(Color.appRed)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("my_babysitters".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("manage_babysitters".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .calcCardStyle()
                    }
                    
                    // STATISTICS Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("statistics".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showStatistics = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.orange.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "chart.pie.fill")
                                                .foregroundColor(.orange)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("statistics".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("view_statistics".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .calcCardStyle()
                    }
                    
                    // CLEAR HISTORY Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("data_management".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            Button(action: {
                                showClearHistoryAlert = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.red.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "trash.fill")
                                                .foregroundColor(.red)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("clear_history".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("delete_all_payment_history".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                        .calcCardStyle()
                    }
                    
                    // PREFERENCES Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("preferences".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            // Currency
                            Button(action: {
                                showCurrencySelection = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "dollarsign.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("currency".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("select_currency".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Text(selectedCurrency.flag)
                                        Text(selectedCurrency.code)
                                            .foregroundColor(Color.appRed)
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 0.2)
                                .padding(.leading, 16)
                            
                            // Language
                            Button(action: {
                                showLanguageSelection = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "globe")
                                                .foregroundColor(Color.appRed)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("language".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("select_app_language".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Text(flagForLanguage(selectedLanguage))
                                        Text(selectedLanguage)
                                            .foregroundColor(Color.appRed)
                                    }
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 0.5)
                                .padding(.leading, 16)
                            
                            // Dark Mode
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "moon.fill")
                                            .foregroundColor(.purple)
                                            .font(.system(size: 16))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("dark_mode".localized)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                    Text("enable_dark_mode".localized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                                    .scaleEffect(0.75)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                                .calcCardStyle()
                    }
                    
                    // SUPPORT Section
                    VStack(alignment: .leading, spacing: 0) {
                        Text("support".localized)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .textCase(.uppercase)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        
                        VStack(spacing: 0) {
                            // Help & Support
                            Button(action: {
                                showHelpSupport = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "questionmark.circle.fill")
                                                .foregroundColor(Color.appRed)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("help_support".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("get_help_contact_support".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 0.2)
                                .padding(.leading, 16)
                            
                            // Terms & Privacy
                            Button(action: {
                                showTermsPrivacy = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("terms_privacy".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("view_terms_privacy_policy".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                            
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(height: 0.5)
                                .padding(.leading, 16)
                            
                            // About
                            Button(action: {
                                showAbout = true
                            }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "info.circle.fill")
                                                .foregroundColor(Color.appRed)
                                                .font(.system(size: 16))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("about".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Text("app_version_information".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)
                        }
                                .calcCardStyle()
                    }
                }
                    .padding(.horizontal)
                    .padding(.top)
                    .padding(.bottom, 40) // Add bottom padding to prevent floating button from hiding content
                }
            }
            .navigationTitle("settings".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .sheet(isPresented: $showCurrencySelection) {
                CurrencySelectionView(
                    selectedCurrency: Binding(
                        get: { selectedCurrency },
                        set: { newCurrency in
                            selectedCurrencyCode = newCurrency.code
                        }
                    ),
                    historyManager: historyManager
                )
            }
            .sheet(isPresented: $showLanguageSelection) {
                LanguageSelectionView(selectedLanguage: $selectedLanguage)
            }
            .sheet(isPresented: $showTermsPrivacy) {
                TermsPrivacyView()
            }
            .sheet(isPresented: $showHelpSupport) {
                HelpSupportView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showBabysitters) {
                BabysittersView()
            }
            .sheet(isPresented: $showStatistics) {
                StatisticsView(historyManager: historyManager)
            }
            .alert("are_you_sure".localized, isPresented: $showClearHistoryAlert) {
                Button("yes".localized, role: .destructive) {
                    clearAllHistory()
                }
                Button("cancel".localized, role: .cancel) { }
            } message: {
                Text("clear_all_history_message".localized)
            }
        }
    }
    
    private func clearAllHistory() {
        // Delete all records for the current user
        let recordsToDelete = historyManager.records
        for record in recordsToDelete {
            historyManager.deleteRecord(record)
        }
    }
}

// Language Selection View
struct LanguageSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLanguage: String
    
    let languages = [
        ("🇬🇧", "English"),
        ("🇩🇪", "German"),
        ("🇫🇷", "French"),
        ("🇸🇪", "Swedish"),
        ("🇪🇸", "Spanish")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 0) {
                            ForEach(Array(languages.enumerated()), id: \.element.1) { index, item in
                                let (flag, language) = item
                                Button(action: {
                                    selectedLanguage = language
                                    LocalizationManager.shared.setLanguage(language)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(flag)
                                        Text(language)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        if language == selectedLanguage {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(Color.appRed)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                }
                                .buttonStyle(.plain)
                                
                                if index < languages.count - 1 {
                                    Divider().padding(.leading, 16)
                                }
                            }
                        }
                        .calcCardStyle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("select_language".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
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

#Preview {
    SettingsView(selectedTab: .constant(0))
}

