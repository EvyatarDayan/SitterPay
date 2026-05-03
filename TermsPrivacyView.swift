//
//  TermsPrivacyView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct TermsPrivacyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                Picker("Section", selection: $selectedTab) {
                    Text("terms_of_use_title".localized).tag(0)
                    Text("privacy_policy_title".localized).tag(1)
                    Text("disclaimer_title".localized).tag(2)
                }
                .pickerStyle(.segmented)
                .padding()
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("terms_of_use_content".localized)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("privacy_policy_content".localized)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("disclaimer_content".localized)
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            }
            .navigationTitle("terms_privacy".localized)
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
        }
    }
}





