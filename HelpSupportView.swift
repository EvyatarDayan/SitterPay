//
//  HelpSupportView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var description = ""
    @State private var showForm = false
    @State private var showError = false
    @State private var showCallAlert = false
    @State private var alertType: AlertType = .none
    
    enum AlertType {
        case none
        case messageSent
        case callSupport
    }
    
    let supportPhone = "+46 123 456 789"
    private let supportEmailAddress = "abashelariprod@gmail.com"
    private let supportWebsiteURL = "https://abashelari.com/"
    
    private func populateUserInfo() {
        // User info can be pre-filled if needed in the future
    }
    
    var allFieldsFilled: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background that extends to top
                Color(.systemGroupedBackground)
                    .ignoresSafeArea(.all)
                
                Group {
                if showForm {
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                CardSectionHeader(title: "your_full_name".localized)
                                TextField("full_name".localized, text: $fullName)
                                    .cardFieldBackground()
                            }
                            .padding(16)
                            .calcCardStyle()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                CardSectionHeader(title: "your_email".localized)
                                TextField("email".localized, text: $email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
                                    .cardFieldBackground()
                            }
                            .padding(16)
                            .calcCardStyle()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                CardSectionHeader(title: "subject".localized)
                                TextField("", text: $subject)
                                    .cardFieldBackground()
                                    .onChange(of: subject) { _, newValue in
                                        if newValue.count > 100 {
                                            subject = String(newValue.prefix(100))
                                        }
                                    }
                                HStack {
                                    Spacer()
                                    Text("\(subject.count)/100")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .calcCardStyle()
                            
                            VStack(alignment: .leading, spacing: 10) {
                                CardSectionHeader(title: "description".localized)
                                TextEditor(text: $description)
                                    .frame(height: 120)
                                    .padding(8)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .onChange(of: description) { _, newValue in
                                        if newValue.count > 400 {
                                            description = String(newValue.prefix(400))
                                        }
                                    }
                                HStack {
                                    Spacer()
                                    Text("\(description.count)/400")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(16)
                            .calcCardStyle()
                            
                            if showError && !allFieldsFilled {
                                Text("all_fields_required".localized)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding(16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .calcCardStyle()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                    .navigationTitle("contact_us".localized)
                    .onAppear { populateUserInfo() }
                    .safeAreaInset(edge: .bottom) {
                        Button(action: {
                            if allFieldsFilled {
                                alertType = .messageSent
                                showError = false
                            } else {
                                showError = true
                            }
                        }) {
                            Text("send".localized)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(allFieldsFilled ? Color.appGreen : Color.gray)
                                .clipShape(Capsule())
                        }
                        .disabled(!allFieldsFilled)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .background(Color(.systemGroupedBackground))
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            VStack(alignment: .center, spacing: 16) {
                                Text("wed_love_to_hear_from_you".localized)
                                    .font(.title3)
                                    .fontWeight(.bold)
                                
                                Text("whether_you_have_questions".localized)
                                    .font(.body)
                                
                                Text("feedback_or_just_want_to_say_hi".localized)
                                    .font(.body)
                                
                                Text("feel_free_to_reach_out".localized)
                                    .font(.body)
                            }
                            .multilineTextAlignment(.center)
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .calcCardStyle()
                            
                            VStack(spacing: 12) {
                                if let emailURL = URL(string: "mailto:\(supportEmailAddress)") {
                                    Link(destination: emailURL) {
                                        Text("email_contact".localized)
                                            .font(.subheadline)
                                            .foregroundColor(Color.appRed)
                                            .underline()
                                    }
                                }
                                
                                if let websiteURL = URL(string: supportWebsiteURL) {
                                    Link(destination: websiteURL) {
                                        Text("website_contact".localized)
                                            .font(.subheadline)
                                            .foregroundColor(Color.appRed)
                                            .underline()
                                    }
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity)
                            .calcCardStyle()
                            
                            Text("we_aim_to_respond_within_24_hours".localized)
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding(16)
                                .frame(maxWidth: .infinity)
                                .calcCardStyle()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical)
                    }
                    .navigationTitle("help_support".localized)
                    .safeAreaInset(edge: .bottom) {
                        Button(action: {
                            populateUserInfo()
                            showForm = true
                        }) {
                            Text("contact_form".localized)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.appGreen)
                                .clipShape(Capsule())
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                        .background(Color(.systemGroupedBackground))
                    }
                }
            }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showForm {
                        Button("cancel".localized) {
                            showForm = false
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showForm {
                        Button("close".localized) {
                            dismiss()
                        }
                        .foregroundColor(Color.appRed)
                    }
                }
            }
            .alert(isPresented: Binding(
                get: { alertType != .none },
                set: { if !$0 { alertType = .none } }
            )) {
                switch alertType {
                case .messageSent:
                    return Alert(
                        title: Text("message_sent".localized),
                        message: Text("thanks_for_reaching_out".localized),
                        dismissButton: .default(Text("ok".localized)) {
                            dismiss()
                        }
                    )
                case .callSupport:
                    return Alert(
                        title: Text("call_support".localized),
                        message: Text("do_you_want_to_call".localized.replacingOccurrences(of: "{phone}", with: supportPhone)),
                        primaryButton: .default(Text("yes".localized)) {
                            if let url = URL(string: "tel://" + supportPhone.filter { $0.isNumber }) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel(Text("no".localized))
                    )
                case .none:
                    return Alert(title: Text(""), message: Text(""), dismissButton: .default(Text("")))
                }
            }
        }
    }
}





