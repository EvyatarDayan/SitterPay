//
//  LoginView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import SwiftUI

// Custom TextField wrapper for better responsiveness
struct ResponsiveTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalizationType: UITextAutocapitalizationType = .sentences
    var onFocusChange: ((Bool) -> Void)?
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.keyboardType = keyboardType
        textField.autocapitalizationType = autocapitalizationType
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
        uiView.isSecureTextEntry = isSecure
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: ResponsiveTextField
        
        init(_ parent: ResponsiveTextField) {
            self.parent = parent
        }
        
        @objc func textChanged(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onFocusChange?(true)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onFocusChange?(false)
        }
    }
}

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userManager: UserManager
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @Binding var selectedTab: Int
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var reenterPassword = ""
    @State private var isSignUp = false
    @State private var profileImage: UIImage?
    @State private var selectedAvatar: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    @State private var showReenterPassword = false
    @State private var showWelcomeAlert = false
    @State private var showWelcomeBackAlert = false
    @State private var loggedInFirstName = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
            ScrollView {
                VStack(spacing: 16) {
                    // Tab Selection
                    HStack(spacing: 0) {
                            // Sign In Tab
                            Button(action: {
                                withAnimation {
                                    // Clear form when switching
                                    firstName = ""
                                    lastName = ""
                                    email = ""
                                    password = ""
                                    reenterPassword = ""
                                    showPassword = false
                                    showReenterPassword = false
                                    // Update state
                                    isSignUp = false
                                }
                            }) {
                                Text("sign_in".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSignUp ? .secondary : .primary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSignUp ? Color.clear : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Sign Up Tab
                            Button(action: {
                                withAnimation {
                                    // Clear form when switching
                                    firstName = ""
                                    lastName = ""
                                    email = ""
                                    password = ""
                                    reenterPassword = ""
                                    showPassword = false
                                    showReenterPassword = false
                                    // Update state
                                    isSignUp = true
                                }
                            }) {
                                Text("sign_up".localized)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(isSignUp ? .primary : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(isSignUp ? Color(.systemGray6) : Color.clear)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(10)
                    .padding(4)
                    .calcCardStyle()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Header Section
                    Group {
                        if isSignUp {
                            // Sign up header
                            VStack(spacing: 16) {
                                Text("create_account".localized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                
                                Text("sign_up_to_sync_your_data".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .id("signup-header")
                        } else {
                            // Login header
                            VStack(spacing: 16) {
                                Text("welcome_back".localized)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                
                                Text("login_to_access_your_account".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.bottom, 8)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .id("signin-header")
                        }
                    }
                    
                    // Form Section
                    VStack(alignment: .leading, spacing: 10) {
                        CardSectionHeader(title: isSignUp ? "account_information".localized : "login_information".localized)
                        
                        VStack(spacing: 12) {
                            if isSignUp {
                                HStack(spacing: 12) {
                                    ResponsiveTextField(
                                        text: $firstName,
                                        placeholder: "first_name".localized,
                                        keyboardType: .default,
                                        autocapitalizationType: .words
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    
                                    ResponsiveTextField(
                                        text: $lastName,
                                        placeholder: "last_name".localized,
                                        keyboardType: .default,
                                        autocapitalizationType: .words
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                                .id("name-fields")
                            }
                            
                            ResponsiveTextField(
                                text: $email,
                                placeholder: "email".localized,
                                keyboardType: .emailAddress,
                                autocapitalizationType: .none
                            )
                            .frame(height: 44)
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            HStack {
                                ResponsiveTextField(
                                    text: $password,
                                    placeholder: "password".localized,
                                    isSecure: !showPassword
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.horizontal, 12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            
                            if isSignUp {
                                HStack {
                                    ResponsiveTextField(
                                        text: $reenterPassword,
                                        placeholder: "reenter_password".localized,
                                        isSecure: !showReenterPassword
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    
                                    Button(action: { showReenterPassword.toggle() }) {
                                        Image(systemName: showReenterPassword ? "eye.slash" : "eye")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .id("reenter-password-field")
                            }
                        }
                    }
                    .padding(16)
                    .calcCardStyle()
                    .padding(.horizontal, 16)
                    .id(isSignUp ? "signup-form" : "signin-form")
                    
                    // Action Buttons Section
                    Button(action: { handleAuthentication() }) {
                        Text(isSignUp ? "sign_up".localized : "sign_in".localized)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(isFormValid ? Color.appRed : Color.gray)
                            .clipShape(Capsule())
                    }
                    .disabled(!isFormValid)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Sign in helper text (only shown in sign in tab)
                    if !isSignUp {
                        VStack(spacing: 4) {
                            Text("please_sign_in_to_use_sitterpay".localized)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 4) {
                                Text("dont_have_an_account".localized + " ")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Button(action: {
                                    withAnimation {
                                        isSignUp = true
                                    }
                                }) {
                                    Text("sign_up".localized)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                                
                                Text(" " + "in_seconds".localized)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                            .multilineTextAlignment(.center)
                        }
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 64)
                    } else {
                        Spacer()
                            .frame(height: 32)
                            .padding(.bottom, 32)
                    }
                }
            }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("done".localized) {
                        // Dismiss keyboard
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
            }
            .alert("authentication".localized, isPresented: $showingAlert) {
                Button("ok".localized) { }
            } message: {
                Text(alertMessage)
            }
            .alert("account_created_successfully".localized, isPresented: $showWelcomeAlert) {
                Button("ok".localized) {
                    // Close the sign up modal after showing welcome message
                    selectedTab = 2 // Navigate to Live Session
                    dismiss()
                }
            } message: {
                Text(String(format: "welcome_first_name".localized, firstName))
            }
            .alert(isPresented: $showWelcomeBackAlert) {
                Alert(
                    title: Text(String(format: "welcome_back_first_name".localized, loggedInFirstName)),
                    dismissButton: .default(Text("ok".localized)) {
                        // Navigate to Live Session and dismiss
                        DispatchQueue.main.async {
                            selectedTab = 2 // Navigate to Live Session
                            dismiss()
                        }
                    }
                )
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && !reenterPassword.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuthentication() {
        if isSignUp {
            // Validate email format
            if !userManager.isEmailValid(email) {
                alertMessage = "please_enter_valid_email".localized
                showingAlert = true
                return
            }
            
            // Validate password match
            if password != reenterPassword {
                alertMessage = "passwords_do_not_match".localized
                showingAlert = true
                return
            }
            
            // Validate password length
            if !userManager.isPasswordValid(password) {
                alertMessage = "password_must_be_at_least_6_characters".localized
                showingAlert = true
                return
            }
            
            // Check if user already exists
            if userManager.isUserExists(email) {
                alertMessage = "account_with_email_already_exists".localized
                showingAlert = true
                return
            }
            
            // Register user (profile image can be set later in profile)
            let success = userManager.registerUser(firstName: firstName, lastName: lastName, email: email, password: password, profileImage: nil, avatarName: nil)
            
            if success {
                // Show welcome popup - it will dismiss the modal when OK is clicked
                showWelcomeAlert = true
            } else {
                alertMessage = "failed_to_create_account".localized
                showingAlert = true
            }
        } else {
            // Login user
            let success = userManager.loginUser(email: email, password: password)
            
            if success {
                // Get the user's first name for the welcome message
                loggedInFirstName = userManager.currentUser?.firstName ?? ""
                showWelcomeBackAlert = true
            } else {
                alertMessage = "invalid_email_or_password".localized
                showingAlert = true
            }
        }
    }
}

