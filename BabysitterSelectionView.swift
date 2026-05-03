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
    @State private var showBabysittersView = false
    
    var body: some View {
        NavigationView {
            Group {
                if babysitterManager.babysitters.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        Text("no_babysitters".localized)
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            showBabysittersView = true
                        }) {
                            Text("add_babysitter".localized)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.appRed)
                                .cornerRadius(12)
                        }
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
            }
            .id(localizationManager.currentLanguage)
            .onAppear {
                // Reload babysitters when view appears to get latest data
                babysitterManager.loadBabysitters()
            }
            .sheet(isPresented: $showBabysittersView) {
                BabysittersView()
            }
            .onChange(of: showBabysittersView) { _, isPresented in
                // Reload babysitters when BabysittersView is dismissed
                if !isPresented {
                    babysitterManager.loadBabysitters()
                }
            }
        }
    }
}

