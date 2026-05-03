//
//  UserManager.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import Foundation
import SwiftUI

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let usersKey = "SavedUsers"
    private let currentUserIdKey = "CurrentUserId"
    
    init() {
        loadCurrentUser()
    }
    
    // MARK: - Authentication
    
    func registerUser(firstName: String, lastName: String, email: String, password: String, profileImage: UIImage? = nil, avatarName: String? = nil) -> Bool {
        // Check if user already exists
        if isUserExists(email) {
            return false
        }
        
        // Validate email
        guard isEmailValid(email) else {
            return false
        }
        
        // Validate password
        guard isPasswordValid(password) else {
            return false
        }
        
        // Convert profile image to data
        var profileImageData: Data? = nil
        if let image = profileImage {
            profileImageData = image.jpegData(compressionQuality: 0.8)
        }
        
        // Create new user
        let newUser = User(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            profileImageData: profileImageData,
            avatarName: avatarName
        )
        
        // Save user
        var users = loadAllUsers()
        users.append(newUser)
        saveAllUsers(users)
        
        // Set as current user
        loginUser(email: email, password: password)
        
        return true
    }
    
    func loginUser(email: String, password: String) -> Bool {
        let users = loadAllUsers()
        
        if let user = users.first(where: { $0.email.lowercased() == email.lowercased() && $0.password == password }) {
            currentUser = user
            isLoggedIn = true
            UserDefaults.standard.set(user.id.uuidString, forKey: currentUserIdKey)
            objectWillChange.send()
            
            // Notify that user changed (for HistoryManager to reload)
            NotificationCenter.default.post(name: NSNotification.Name("UserDidChange"), object: nil)
            
            return true
        }
        
        return false
    }
    
    func logoutUser() {
        currentUser = nil
        isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: currentUserIdKey)
        objectWillChange.send()
        
        // Notify that user changed (for HistoryManager to clear data)
        NotificationCenter.default.post(name: NSNotification.Name("UserDidChange"), object: nil)
    }
    
    // MARK: - User Management
    
    func updateUserProfile(firstName: String, lastName: String, profileImage: UIImage? = nil, avatarName: String? = nil, phoneNumber: String? = nil, countryCode: String? = nil) -> Bool {
        guard var user = currentUser else {
            return false
        }
        
        // Validate email (if changed)
        guard isEmailValid(user.email) else {
            return false
        }
        
        // Update user properties
        user.firstName = firstName
        user.lastName = lastName
        
        // Update profile image
        if let image = profileImage {
            user.profileImageData = image.jpegData(compressionQuality: 0.8)
            user.avatarName = nil // Clear avatar when image is set
        } else if avatarName != nil {
            user.avatarName = avatarName
            user.profileImageData = nil // Clear image when avatar is set
        }
        
        // Save updated user
        var users = loadAllUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveAllUsers(users)
            currentUser = user
            objectWillChange.send()
            return true
        }
        
        return false
    }
    
    func updatePassword(currentPassword: String, newPassword: String) -> Bool {
        guard var user = currentUser else {
            return false
        }
        
        // Verify current password
        guard user.password == currentPassword else {
            return false
        }
        
        // Validate new password
        guard isPasswordValid(newPassword) else {
            return false
        }
        
        // Update password
        user.password = newPassword
        
        // Save updated user
        var users = loadAllUsers()
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            saveAllUsers(users)
            currentUser = user
            objectWillChange.send()
            return true
        }
        
        return false
    }
    
    func deleteProfile() {
        guard let user = currentUser else {
            return
        }
        
        // Remove user from saved users
        var users = loadAllUsers()
        users.removeAll { $0.id == user.id }
        saveAllUsers(users)
        
        // Logout
        logoutUser()
    }
    
    // MARK: - Helper Methods
    
    func isUserExists(_ email: String) -> Bool {
        let users = loadAllUsers()
        return users.contains { $0.email.lowercased() == email.lowercased() }
    }
    
    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    func getProfileImage() -> UIImage? {
        guard let user = currentUser,
              let imageData = user.profileImageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    func getAvatarName() -> String? {
        return currentUser?.avatarName
    }
    
    // MARK: - Private Methods
    
    private func loadCurrentUser() {
        guard let userIdString = UserDefaults.standard.string(forKey: currentUserIdKey),
              let userId = UUID(uuidString: userIdString) else {
            isLoggedIn = false
            return
        }
        
        let users = loadAllUsers()
        if let user = users.first(where: { $0.id == userId }) {
            currentUser = user
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    
    private func loadAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    private func saveAllUsers(_ users: [User]) {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
    
    // Check if any user has ever signed up
    func hasAnyUserSignedUp() -> Bool {
        let users = loadAllUsers()
        return !users.isEmpty
    }
}

