//
//  BabysitterSelectionView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct BabysitterSelectionView: View {
    @ObservedObject var babysitterManager: BabysitterManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    let onSelect: (Babysitter) -> Void
    @State private var showAddBabysitter = false
    
    var body: some View {
        NavigationView {
            Group {
                if babysitterManager.babysitters.isEmpty {
                    VStack {
                        Spacer()
                        Text("no_babysitters_select_message".localized)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(babysitterManager.babysitters) { babysitter in
                            Button(action: {
                                onSelect(babysitter)
                            }) {
                                BabysitterRowView(babysitter: babysitter, onNameTap: {
                                    onSelect(babysitter)
                                })
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                                .background(
                                    Color(uiColor: UIColor { traitCollection in
                                        traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                    })
                                )
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color(.systemGroupedBackground))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 4))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("select_babysitter".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("close".localized) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddBabysitter = true
                    }) {
                        Image("Add")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(Color.appRed)
                    }
                }
            }
            .id(localizationManager.currentLanguage)
            .onAppear {
                // Reload babysitters when view appears to get latest data
                babysitterManager.loadBabysitters()
            }
            .sheet(isPresented: $showAddBabysitter) {
                AddEditBabysitterView(
                    babysitterManager: babysitterManager,
                    babysitter: nil
                )
            }
            .onChange(of: showAddBabysitter) { _, isPresented in
                if !isPresented {
                    babysitterManager.loadBabysitters()
                }
            }
        }
    }
}

