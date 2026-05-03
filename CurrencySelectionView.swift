//
//  CurrencySelectionView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct CurrencySelectionView: View {
    @Binding var selectedCurrency: Currency
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @State private var tempSelectedCurrency: Currency
    @State private var showConfirmationAlert: Bool = false
    @State private var pendingCurrency: Currency?
    var historyManager: HistoryManager?
    
    init(selectedCurrency: Binding<Currency>, historyManager: HistoryManager? = nil) {
        self._selectedCurrency = selectedCurrency
        self._tempSelectedCurrency = State(initialValue: selectedCurrency.wrappedValue)
        self.historyManager = historyManager
    }
    
    private var filteredCurrencies: [Currency] {
        if searchText.isEmpty {
            return Currency.allCurrencies
        } else {
            return Currency.allCurrencies.filter { currency in
                currency.code.localizedCaseInsensitiveContains(searchText) ||
                currency.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                VStack {
                    SearchBar(text: $searchText)
                    
                    List {
                    ForEach(filteredCurrencies) { currency in
                        HStack {
                            Text(currency.flag)
                                .font(.title2)
                            
                            Text("\(currency.code) - \(currency.name)")
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if tempSelectedCurrency.id == currency.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.appRed)
                            }
                        }
                        .listRowBackground(
                            Color(uiColor: UIColor { traitCollection in
                                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                            })
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // If currency is different from current, show confirmation
                            if currency.code != selectedCurrency.code {
                                pendingCurrency = currency
                                tempSelectedCurrency = currency
                                showConfirmationAlert = true
                            } else {
                                // Same currency, just dismiss
                                dismiss()
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            }
            .navigationTitle("select_currency_title".localized)
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
            .alert("are_you_sure".localized, isPresented: $showConfirmationAlert) {
                Button("no".localized, role: .cancel) {
                    // Reset temp selection to original currency
                    tempSelectedCurrency = selectedCurrency
                    pendingCurrency = nil
                }
                Button("yes".localized) {
                    // Apply the currency change
                    if let newCurrency = pendingCurrency {
                        // Update all history records to new currency
                        historyManager?.updateAllRecordsCurrency(to: newCurrency.code)
                        
                        // Update the selected currency
                        selectedCurrency = newCurrency
                        tempSelectedCurrency = newCurrency
                        
                        // Dismiss the modal
                        dismiss()
                    }
                    pendingCurrency = nil
                }
            } message: {
                if let currency = pendingCurrency {
                    Text("Are you sure? all history items will be updated to \(currency.flag) \(currency.code)")
                } else {
                    Text("")
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Currency", text: $text)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

#Preview {
    CurrencySelectionView(selectedCurrency: .constant(Currency.allCurrencies[0]))
}

