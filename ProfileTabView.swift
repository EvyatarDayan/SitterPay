//
//  ProfileTabView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-30.
//

import SwiftUI

struct ProfileTabView: View {
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        ProfileView()
    }
}

