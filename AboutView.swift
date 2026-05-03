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
                VStack(alignment: .leading, spacing: 24) {
                    // About SitterPay Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("about_sitterpay_title".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("about_sitterpay_content".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Color(uiColor: UIColor { traitCollection in
                            traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                        })
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // About ABASHELARI Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("about_abashelari_title".localized)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("about_abashelari_content".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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





