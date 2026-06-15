//
//  ProfileView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    var selectedTab: Binding<Int>?
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var profileImage: UIImage?
    @State private var selectedAvatar: String?
    @State private var showingPasswordUpdate = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSaved = false
    @Environment(\.dismiss) private var dismiss
    
    // Store original values to detect changes
    @State private var originalFirstName: String = ""
    @State private var originalLastName: String = ""
    @State private var originalProfileImage: UIImage?
    @State private var originalSelectedAvatar: String?
    
    init(selectedTab: Binding<Int>? = nil) {
        // Initialize from current user if available
        let user = UserManager.shared.currentUser
        let originalFirstName = user?.firstName ?? ""
        let originalLastName = user?.lastName ?? ""
        let originalEmail = user?.email ?? ""
        let originalProfileImage = UserManager.shared.getProfileImage()
        let originalSelectedAvatar = UserManager.shared.getAvatarName()
        
        _firstName = State(initialValue: originalFirstName)
        _lastName = State(initialValue: originalLastName)
        _email = State(initialValue: originalEmail)
        _profileImage = State(initialValue: originalProfileImage)
        _selectedAvatar = State(initialValue: originalSelectedAvatar)
        
        // Store original values
        _originalFirstName = State(initialValue: originalFirstName)
        _originalLastName = State(initialValue: originalLastName)
        _originalProfileImage = State(initialValue: originalProfileImage)
        _originalSelectedAvatar = State(initialValue: originalSelectedAvatar)
        
        // Store selectedTab binding
        self.selectedTab = selectedTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 16) {
                            ProfileImageSelector(selectedImage: $profileImage, selectedAvatar: $selectedAvatar, onImageChange: {
                                isSaved = false
                            })
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .calcCardStyle()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            CardSectionHeader(title: "personal_information".localized)
                            
                            HStack(spacing: 12) {
                                TextField("first_name".localized, text: $firstName)
                                    .onChange(of: firstName) { _, _ in isSaved = false }
                                    .cardFieldBackground()
                                
                                TextField("last_name".localized, text: $lastName)
                                    .onChange(of: lastName) { _, _ in isSaved = false }
                                    .cardFieldBackground()
                            }
                            
                            Text(email)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .cardFieldBackground()
                            
                            Text("email_cannot_be_updated".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .calcCardStyle()
                        
                        VStack(spacing: 0) {
                            Button(action: { showingPasswordUpdate = true }) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.2))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "lock.fill")
                                                .foregroundColor(.blue)
                                                .font(.system(size: 14))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("update_password".localized)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("change_your_account_password".localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                            }
                            .buttonStyle(.plain)
                        }
                        .calcCardStyle()
                        
                        Button(action: { showingDeleteAccountAlert = true }) {
                            Text("delete_account".localized)
                                .font(.body)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(16)
                        }
                        .calcCardStyle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical)
                }
            }
            .navigationTitle("edit_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(buttonTitle) {
                        handleLeadingButtonAction()
                    }
                    .foregroundColor(buttonColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("logout".localized) {
                        userManager.logoutUser()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("delete_account".localized, isPresented: $showingDeleteAccountAlert) {
                Button("cancel".localized, role: .cancel) { }
                Button("delete".localized, role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text("are_you_sure_delete_account".localized)
            }
            .alert(Text(alertMessage), isPresented: $showingAlert) {
                Button("ok".localized) { }
            }
            .sheet(isPresented: $showingPasswordUpdate) {
                UpdatePasswordView()
            }
        }
    }
    
    private var buttonTitle: String {
        if isSaved {
            return "close".localized
        } else if isFormValid {
            return "save".localized
        } else {
            return "cancel".localized
        }
    }
    
    private var buttonColor: Color {
        return .blue
    }
    
    private func handleLeadingButtonAction() {
        if isSaved {
            // Close button - dismiss modal
            dismiss()
        } else if isFormValid {
            // Save button - save profile
            saveProfile()
        } else {
            // Cancel button - dismiss modal
            dismiss()
        }
    }
    
    private var isFormValid: Bool {
        // Check if form fields are filled
        guard !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty else {
            return false
        }
        
        // Check if any changes were made
        let nameChanged = firstName != originalFirstName || lastName != originalLastName
        let avatarChanged = selectedAvatar != originalSelectedAvatar
        
        // Compare images by data
        let imageChanged: Bool
        if profileImage == nil && originalProfileImage == nil {
            imageChanged = false
        } else if profileImage == nil || originalProfileImage == nil {
            imageChanged = true
        } else {
            // Compare image data
            let currentImageData = profileImage?.jpegData(compressionQuality: 1.0)
            let originalImageData = originalProfileImage?.jpegData(compressionQuality: 1.0)
            imageChanged = currentImageData != originalImageData
        }
        
        return nameChanged || imageChanged || avatarChanged
    }
    
    private func saveProfile() {
        // Validate email format
        if !userManager.isEmailValid(email) {
            alertMessage = "please_enter_valid_email".localized
            showingAlert = true
            return
        }
        
        // Update user profile
        let success = userManager.updateUserProfile(
            firstName: firstName,
            lastName: lastName,
            profileImage: profileImage,
            avatarName: selectedAvatar,
            phoneNumber: nil,
            countryCode: nil
        )
        
        if success {
            // Update original values to reflect the saved state
            originalFirstName = firstName
            originalLastName = lastName
            originalProfileImage = profileImage
            originalSelectedAvatar = selectedAvatar
            
            // Mark as saved to show "Done" button
            isSaved = true
            
            // Show success message
            alertMessage = "profile_data_updated".localized
            showingAlert = true
        } else {
            alertMessage = "failed_to_update_profile".localized
            showingAlert = true
        }
    }
    
    private func deleteAccount() {
        guard let userId = userManager.currentUser?.id else {
            return
        }
        
        // Delete all history records for this user
        let historyManager = HistoryManager()
        let userRecords = historyManager.records.filter { $0.userId == userId }
        for record in userRecords {
            historyManager.deleteRecord(record)
        }
        
        // Delete all babysitters for this user
        let babysitterManager = BabysitterManager()
        babysitterManager.deleteBabysittersForUser(userId)
        
        // Delete the user account
        userManager.deleteProfile()
        
        // Navigate to Live Session view and dismiss modal
        DispatchQueue.main.async {
            selectedTab?.wrappedValue = 2 // Navigate to Live Session
            dismiss()
        }
    }
}

// Profile Image Selector Component
struct ProfileImageSelector: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedAvatar: String?
    var onImageChange: (() -> Void)?
    @State private var showingImagePicker = false
    @State private var showingAvatarPicker = false
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    // Store temporary values to restore if cancelled
    @State private var tempSelectedImage: UIImage?
    @State private var tempSelectedAvatar: String?
    
    var body: some View {
        HStack(spacing: 16) {
            // Current selection display - NOT a button
            Group {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else if let selectedAvatar = selectedAvatar {
                    Image(selectedAvatar)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        )
                }
            }
            
            Spacer()
            
            // Two separate buttons
            VStack(spacing: 6) {
                // Library Button
                Button {
                    // Store current values before opening picker
                    tempSelectedImage = selectedImage
                    tempSelectedAvatar = selectedAvatar
                    selectedAvatar = nil
                    showingImagePicker = true
                } label: {
                    Text("library".localized)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(minWidth: 60)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Color(uiColor: UIColor { traitCollection in
                                traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.systemGray6
                            })
                        )
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())

                // Avatar Button
                Button {
                    // Store current values before opening picker
                    tempSelectedImage = selectedImage
                    tempSelectedAvatar = selectedAvatar
                    selectedImage = nil
                    showingAvatarPicker = true
                } label: {
                    Text("avatar".localized)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .frame(minWidth: 60)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Color(uiColor: UIColor { traitCollection in
                                traitCollection.userInterfaceStyle == .dark ? UIColor.systemGray5 : UIColor.systemGray6
                            })
                        )
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, onCancel: {
                // Restore original values if cancelled
                selectedImage = tempSelectedImage
                selectedAvatar = tempSelectedAvatar
            }, onImageSelected: {
                onImageChange?()
            })
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPicker(selectedAvatar: $selectedAvatar, onCancel: {
                // Restore original values if cancelled
                selectedImage = tempSelectedImage
                selectedAvatar = tempSelectedAvatar
            }, onAvatarSelected: {
                onImageChange?()
            })
        }
    }
}

// Image Picker Component
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var onCancel: (() -> Void)?
    var onImageSelected: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.onImageSelected?()
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel?()
            parent.dismiss()
        }
    }
}

// Update Password View
struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("update_password".localized)
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text("enter_your_current_password_and_choose_new_one".localized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .calcCardStyle()
                        
                        VStack(alignment: .leading, spacing: 10) {
                            CardSectionHeader(title: "password_information".localized)
                            
                            passwordField(
                                text: $currentPassword,
                                placeholder: "current_password".localized,
                                isVisible: $isCurrentPasswordVisible
                            )
                            
                            passwordField(
                                text: $newPassword,
                                placeholder: "new_password".localized,
                                isVisible: $isNewPasswordVisible
                            )
                            
                            passwordField(
                                text: $confirmPassword,
                                placeholder: "reenter_new_password".localized,
                                isVisible: $isConfirmPasswordVisible
                            )
                        }
                        .padding(16)
                        .calcCardStyle()
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("password_requirements".localized)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                            Text("at_least_6_characters_long".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("new_password_must_be_different_from_current".localized)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .calcCardStyle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("update_password".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(action: updatePassword) {
                    Text("update_password".localized)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(isFormValid ? Color.appRed : Color.gray)
                        .clipShape(Capsule())
                }
                .disabled(!isFormValid)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.systemGroupedBackground))
            }
            .alert("password_update".localized, isPresented: $showingAlert) {
                Button("ok".localized) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func passwordField(text: Binding<String>, placeholder: String, isVisible: Binding<Bool>) -> some View {
        HStack {
            Group {
                if isVisible.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)
            
            Button(action: { isVisible.wrappedValue.toggle() }) {
                Image(systemName: isVisible.wrappedValue ? "eye.slash" : "eye")
                    .foregroundColor(.secondary)
            }
        }
        .cardFieldBackground()
    }
    
    private var isFormValid: Bool {
        return !currentPassword.isEmpty && 
               !newPassword.isEmpty && 
               !confirmPassword.isEmpty &&
               newPassword == confirmPassword &&
               newPassword != currentPassword &&
               userManager.isPasswordValid(newPassword)
    }
    
    private func updatePassword() {
        // Validate passwords match
        guard newPassword == confirmPassword else {
            alertMessage = "new_passwords_do_not_match".localized
            showingAlert = true
            return
        }
        
        // Validate new password is different from current
        guard newPassword != currentPassword else {
            alertMessage = "new_password_must_be_different_from_current_password".localized
            showingAlert = true
            return
        }
        
        // Validate new password strength
        guard userManager.isPasswordValid(newPassword) else {
            alertMessage = "new_password_must_be_at_least_6_characters_long".localized
            showingAlert = true
            return
        }
        
        // Update password
        let success = userManager.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
        
        if success {
            alertMessage = "password_updated_successfully".localized
            showingAlert = true
            
            // Clear form
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            
            // Dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = "incorrect_current_password".localized
            showingAlert = true
        }
    }
}

// Avatar Picker View
struct AvatarPicker: View {
    @Binding var selectedAvatar: String?
    var onCancel: (() -> Void)?
    var onAvatarSelected: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    
    // Avatar names matching the asset names
    private let avatarNames = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(avatarNames, id: \.self) { avatarName in
                        Button(action: {
                            selectedAvatar = avatarName
                            onAvatarSelected?()
                            dismiss()
                        }) {
                            VStack {
                                Image(avatarName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedAvatar == avatarName ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("choose_avatar".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("cancel".localized) {
                        onCancel?()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView(selectedTab: nil)
}
