//
//  SelectBabysitterPopupView.swift
//  SitterPay
//
//  Created for Live Session Select Popup
//

import SwiftUI

struct SelectBabysitterPopupView: View {
    @ObservedObject var babysitterManager: BabysitterManager
    @Binding var babysitterName: String
    @Binding var hourlyRate: String
    @Binding var otherPays: String
    let currencySymbol: String
    let onDismiss: () -> Void
    
    @State private var showAddBabysitter = false
    @State private var editingBabysitter: Babysitter?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
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
                                    babysitterName = babysitter.name
                                    if let rate = babysitter.hourlyRate {
                                        hourlyRate = PaymentFormat.amount(rate)
                                    }
                                    if let other = babysitter.otherPays {
                                        otherPays = PaymentFormat.amount(other)
                                    }
                                    onDismiss()
                                }) {
                                    HStack(alignment: .center) {
                                        Text(babysitter.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if let rate = babysitter.hourlyRate {
                                            Text("\(PaymentFormat.currency(rate, symbol: currencySymbol))/hr")
                                                .font(.subheadline)
                                                .foregroundColor(Color.appRed)
                                        }
                                    }
                                    .frame(height: 60)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                                    .calcCardStyle()
                                }
                                .listRowBackground(Color(.systemGroupedBackground))
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets.cardListRow)
                            }
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("select_babysitter".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        onDismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        editingBabysitter = nil
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
            .sheet(isPresented: $showAddBabysitter) {
                AddEditBabysitterView(
                    babysitterManager: babysitterManager,
                    babysitter: nil
                )
            }
            .sheet(item: $editingBabysitter) { babysitter in
                AddEditBabysitterView(
                    babysitterManager: babysitterManager,
                    babysitter: babysitter
                )
            }
            .onAppear {
                // Reload babysitters when view appears
                babysitterManager.loadBabysitters()
            }
            .onChange(of: showAddBabysitter) { oldValue, newValue in
                // Reload babysitters when AddEditBabysitterView is dismissed
                if oldValue && !newValue {
                    babysitterManager.loadBabysitters()
                }
            }
            .onChange(of: editingBabysitter) { oldValue, newValue in
                // Reload babysitters when editing is dismissed
                if oldValue != nil && newValue == nil {
                    babysitterManager.loadBabysitters()
                }
            }
        }
    }
}
