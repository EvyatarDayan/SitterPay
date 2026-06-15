//
//  BabysittersView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI
import MapKit
import Contacts
import ContactsUI

struct BabysittersView: View {
    @StateObject private var babysitterManager = BabysitterManager()
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var showAddBabysitter = false
    @State private var editingBabysitter: Babysitter?
    @Environment(\.dismiss) var dismiss
    
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
                            BabysitterRowView(
                                babysitter: babysitter,
                                onNameTap: {
                                    editingBabysitter = babysitter
                                }
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .background(
                                Color(uiColor: UIColor { traitCollection in
                                    traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
                                })
                            )
                            .cornerRadius(12)
                            .listRowBackground(Color(.systemGroupedBackground))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 4, bottom: 6, trailing: 4))
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                babysitterManager.deleteBabysitter(babysitterManager.babysitters[index])
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("my_babysitters".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("close".localized)
                            .foregroundColor(Color.appRed)
                    }
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
            .id(localizationManager.currentLanguage)
        }
    }
}

// Babysitter Row View
struct BabysitterRowView: View {
    let babysitter: Babysitter
    let onNameTap: () -> Void
    @State private var showCallAlert = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        HStack(alignment: .center) {
            // Name area - clickable to edit
            Text(babysitter.name)
                .font(.headline)
                .foregroundColor(.primary)
                .contentShape(Rectangle())
                .onTapGesture {
                    onNameTap()
                }
            
            Spacer()
            
            // Phone number - clickable to call, on the right side
            if !babysitter.phoneNumber.isEmpty {
                Button(action: {
                    showCallAlert = true
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                        Text(babysitter.phoneNumber)
                            .font(.body)
                    }
                    .foregroundColor(Color.appRed)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 60) // Fixed height per item
        .alert(String(format: "do_you_want_to_call_name".localized, babysitter.name), isPresented: $showCallAlert) {
            Button("cancel".localized, role: .cancel) { }
            Button("call".localized) {
                if let url = URL(string: "tel://\(babysitter.phoneNumber.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: ""))") {
                    UIApplication.shared.open(url)
                }
            }
        } message: {
            Text(babysitter.phoneNumber)
        }
    }
}

// Add/Edit Babysitter View
struct AddEditBabysitterView: View {
    @ObservedObject var babysitterManager: BabysitterManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    
    let babysitter: Babysitter?
    
    @State private var name: String = ""
    @State private var address: String = ""
    @State private var phoneNumber: String = ""
    @State private var email: String = ""
    @State private var hourlyRate: String = ""
    @State private var otherPays: String = ""
    
    @State private var showValidationError = false
    @State private var showAddressSuggestions = false
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var searchResults: [MKLocalSearchCompletion] = []
    @StateObject private var completerDelegate = SearchCompleterDelegate()
    @State private var showContactPicker = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, address, phoneNumber, email, hourlyRate, otherPays
    }
    
    var isEditMode: Bool {
        babysitter != nil
    }
    
    // Get existing addresses for fallback autocomplete
    private var existingAddresses: [String] {
        Array(Set(babysitterManager.babysitters.compactMap { $0.address.isEmpty ? nil : $0.address })).sorted()
    }
    
    // Combined suggestions: existing addresses first, then MapKit results
    private var allAddressSuggestions: [(id: String, title: String, subtitle: String)] {
        var suggestions: [(id: String, title: String, subtitle: String)] = []
        
        // Prioritize existing addresses that match, but exclude the current address to avoid duplication
        let matchingExisting = existingAddresses
            .filter { existingAddr in
                // Exclude exact matches to prevent showing the current address in suggestions
                existingAddr.localizedCaseInsensitiveCompare(address) != .orderedSame &&
                existingAddr.localizedCaseInsensitiveContains(address) &&
                !address.isEmpty
            }
            .prefix(5)
            .map { (id: "existing_\($0)", title: $0, subtitle: "") }
        
        suggestions.append(contentsOf: matchingExisting)
        
        // Add MapKit results if we have fewer than 5 existing matches
        if suggestions.count < 5 {
            let mapKitSuggestions = searchResults.prefix(5 - suggestions.count).map { completion in
                // Create unique ID from title and subtitle
                let uniqueId = "\(completion.title)_\(completion.subtitle)"
                return (id: uniqueId, title: completion.title, subtitle: completion.subtitle)
            }
            suggestions.append(contentsOf: mapKitSuggestions)
        }
        
        return suggestions
    }
    
    // Validation
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)) != nil &&
        isValidEmail(email.isEmpty ? "" : email)
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        if email.isEmpty {
            return true // Email is optional
        }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Name field
                    nameField
                    
                    // Address field with autocomplete
                    addressField
                    
                    // Phone field
                    phoneField
                    
                    // Email field
                    emailField
                    
                    // Hourly rate and Extras in one row
                    payFields
                }
                .padding(.top, 20)
                .padding(.bottom, 100) // Space for save button
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle(isEditMode ? "edit_babysitter".localized : "add_babysitter".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .foregroundColor(Color.appRed)
                }
            }
            .safeAreaInset(edge: .bottom) {
                saveButton
            }
            .sheet(isPresented: $showContactPicker) {
                ContactPickerView(
                    onContactSelected: { contact in
                        loadContactDetails(contact)
                        showContactPicker = false
                    },
                    onDismiss: {
                        showContactPicker = false
                    }
                )
            }
            .onAppear {
                // Setup MapKit search completer
                searchCompleter.resultTypes = .address
                searchCompleter.delegate = completerDelegate
                completerDelegate.onUpdate = { results in
                    searchResults = results
                }
                
                if let babysitter = babysitter {
                    name = babysitter.name
                    address = babysitter.address
                    phoneNumber = babysitter.phoneNumber
                    email = babysitter.email
                    hourlyRate = babysitter.hourlyRate != nil ? String(format: "%.2f", babysitter.hourlyRate!) : ""
                    otherPays = babysitter.otherPays != nil ? String(format: "%.2f", babysitter.otherPays!) : ""
                    // Don't show suggestions when loading existing address
                    showAddressSuggestions = false
                }
            }
            .id(localizationManager.currentLanguage)
        }
    }
    
    // MARK: - View Components
    
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("name".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    showContactPicker = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.caption)
                        Text("from_contacts".localized)
                            .font(.caption)
                    }
                    .foregroundColor(Color.appRed)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appRed.opacity(0.1))
                    .cornerRadius(6)
                }
            }
            
            TextField("name".localized, text: $name)
                .font(.body)
                .focused($focusedField, equals: .name)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationError && name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: name) { oldValue, newValue in
                    if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Clear error when user starts typing
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 85)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var addressField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("address".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ZStack(alignment: .topLeading) {
                TextField("address".localized, text: $address)
                    .font(.body)
                    .focused($focusedField, equals: .address)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .onChange(of: address) { oldValue, newValue in
                        // Show suggestions if we have existing matches or if user typed enough for MapKit
                        if !newValue.isEmpty {
                            let hasExistingMatches = !existingAddresses.filter { $0.localizedCaseInsensitiveContains(newValue) }.isEmpty
                            
                            if hasExistingMatches {
                                showAddressSuggestions = true
                            } else if newValue.count >= 3 {
                                // Use MapKit search completer when user types 3+ characters
                                searchCompleter.queryFragment = newValue
                                showAddressSuggestions = true
                            } else {
                                showAddressSuggestions = false
                            }
                        } else {
                            showAddressSuggestions = false
                            searchCompleter.queryFragment = ""
                        }
                    }
                    .onChange(of: focusedField) { oldValue, newValue in
                        if newValue == .address && !address.isEmpty {
                            showAddressSuggestions = true
                        } else if newValue != .address {
                            // Delay hiding to allow tap
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                showAddressSuggestions = false
                            }
                        }
                    }
                
                // Address suggestions from MapKit + existing addresses
                if showAddressSuggestions && !allAddressSuggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(allAddressSuggestions.prefix(5).enumerated()), id: \.element.id) { index, suggestion in
                            Button(action: {
                                // Combine title and subtitle for full address
                                let fullAddress = suggestion.subtitle.isEmpty ? suggestion.title : "\(suggestion.title), \(suggestion.subtitle)"
                                address = fullAddress
                                showAddressSuggestions = false
                                focusedField = nil
                            }) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color(.systemBackground))
                            }
                            .buttonStyle(.plain)
                            
                            if index < allAddressSuggestions.prefix(5).count - 1 {
                                Divider()
                                    .padding(.leading, 12)
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.top, 40)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 85)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("phone_number".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("phone_number".localized, text: $phoneNumber)
                .keyboardType(.phonePad)
                .font(.body)
                .focused($focusedField, equals: .phoneNumber)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationError && phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: phoneNumber) { oldValue, newValue in
                    // Only allow numbers, spaces, dashes, and parentheses
                    let filtered = newValue.filter { "0123456789 -()".contains($0) }
                    if filtered != newValue {
                        phoneNumber = filtered
                    }
                    if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Clear error when user starts typing
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 85)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("email".localized)
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("email".localized, text: $email)
                .keyboardType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .font(.body)
                .focused($focusedField, equals: .email)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(showValidationError && !email.isEmpty && !isValidEmail(email) ? Color.red : Color.clear, lineWidth: 2)
                )
                .onChange(of: email) { oldValue, newValue in
                    if showValidationError && (newValue.isEmpty || isValidEmail(newValue)) {
                        // Clear error when email is empty or becomes valid
                    }
                }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(height: 85)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var payFields: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("hourly_rate".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        TextField("0.00", text: $hourlyRate)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .focused($focusedField, equals: .hourlyRate)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(showValidationError && (hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)) == nil) ? Color.red : Color.clear, lineWidth: 2)
                            )
                            .onChange(of: hourlyRate) { oldValue, newValue in
                                // Only allow numbers and decimal point
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    hourlyRate = filtered
                                }
                                if showValidationError && !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && Double(newValue.trimmingCharacters(in: .whitespacesAndNewlines)) != nil {
                                    // Clear error when user enters valid value
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(width: 0.5)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("extras".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        TextField("0.00", text: $otherPays)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .focused($focusedField, equals: .otherPays)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .onChange(of: otherPays) { oldValue, newValue in
                                // Only allow numbers and decimal point
                                let filtered = newValue.filter { "0123456789.".contains($0) }
                                if filtered != newValue {
                                    otherPays = filtered
                                }
                            }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .frame(height: 85)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color(uiColor: UIColor { traitCollection in
                traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
            })
        )
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var saveButton: some View {
        Button(action: {
            saveBabysitter()
        }) {
            Text("save".localized)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.appRed)
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .background(Color(.systemGroupedBackground))
    }
    
    private func saveBabysitter() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedHourlyRate = hourlyRate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Always show validation errors
        showValidationError = true
        
        // Check all validations
        var hasErrors = false
        
        if trimmedName.isEmpty {
            hasErrors = true
        }
        
        let trimmedPhoneNumber = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedPhoneNumber.isEmpty {
            hasErrors = true
        }
        
        if trimmedHourlyRate.isEmpty || Double(trimmedHourlyRate) == nil {
            hasErrors = true
        }
        
        if !email.isEmpty && !isValidEmail(email) {
            hasErrors = true
        }
        
        // If there are errors, don't save (red borders will show the errors)
        if hasErrors {
            return
        }
        
        // All validations passed, save
        let hourlyRateValue = Double(trimmedHourlyRate)!
        let otherPaysValue = Double(otherPays.trimmingCharacters(in: .whitespacesAndNewlines))
        
        if let existingBabysitter = babysitter {
            // Update existing
            let updatedBabysitter = Babysitter(
                id: existingBabysitter.id,
                userId: UUID(), // Dummy UUID for backward compatibility
                name: trimmedName,
                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                hourlyRate: hourlyRateValue,
                otherPays: otherPaysValue
            )
            babysitterManager.updateBabysitter(updatedBabysitter)
        } else {
            // Add new
            let newBabysitter = Babysitter(
                userId: UUID(), // Dummy UUID for backward compatibility
                name: trimmedName,
                address: address.trimmingCharacters(in: .whitespacesAndNewlines),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines),
                email: email.trimmingCharacters(in: .whitespacesAndNewlines),
                hourlyRate: hourlyRateValue,
                otherPays: otherPaysValue
            )
            babysitterManager.addBabysitter(newBabysitter)
        }
        
        dismiss()
    }
    
    // Load contact details into form fields
    private func loadContactDetails(_ contact: CNContact) {
        // Name
        if !contact.givenName.isEmpty || !contact.familyName.isEmpty {
            name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        }
        
        // Phone number (get first phone number)
        if let phoneNumberValue = contact.phoneNumbers.first?.value.stringValue {
            // Remove formatting characters
            phoneNumber = phoneNumberValue.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        }
        
        // Email (get first email)
        if let emailValue = contact.emailAddresses.first?.value as String? {
            email = emailValue
        }
        
        // Address (get first postal address)
        if let postalAddress = contact.postalAddresses.first?.value {
            var addressComponents: [String] = []
            if !postalAddress.street.isEmpty {
                addressComponents.append(postalAddress.street)
            }
            if !postalAddress.city.isEmpty {
                addressComponents.append(postalAddress.city)
            }
            if !postalAddress.state.isEmpty {
                addressComponents.append(postalAddress.state)
            }
            if !postalAddress.postalCode.isEmpty {
                addressComponents.append(postalAddress.postalCode)
            }
            if !postalAddress.country.isEmpty {
                addressComponents.append(postalAddress.country)
            }
            address = addressComponents.joined(separator: ", ")
        }
    }
}

// Contact Picker View
struct ContactPickerView: UIViewControllerRepresentable {
    let onContactSelected: (CNContact) -> Void
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: ContactPickerView
        
        init(_ parent: ContactPickerView) {
            self.parent = parent
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Dismiss the picker first, then call the callback
            picker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.parent.onContactSelected(contact)
                }
            }
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            picker.dismiss(animated: true) {
                DispatchQueue.main.async {
                    self.parent.onDismiss()
                }
            }
        }
    }
}

// Helper delegate for MKLocalSearchCompleter
class SearchCompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var onUpdate: (([MKLocalSearchCompletion]) -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onUpdate?(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        onUpdate?([])
    }
}

#Preview {
    BabysittersView()
}
