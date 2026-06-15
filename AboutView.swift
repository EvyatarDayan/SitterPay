//
//  AboutView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        CardSectionHeader(title: "about_sitterpay_title".localized)
                        
                        Text("about_sitterpay_content".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .calcCardStyle()
                    
                    VStack(alignment: .leading, spacing: 12) {
                        CardSectionHeader(title: "about_abashelari_title".localized)
                        
                        Text("about_abashelari_content".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .calcCardStyle()
                }
                .padding(.horizontal, 16)
                .padding(.vertical)
            }
            }
            .navigationTitle("about".localized)
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





