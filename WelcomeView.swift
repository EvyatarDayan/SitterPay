//
//  WelcomeView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-12-22.
//

import SwiftUI

enum WelcomeStorage {
    static let skipWelcomeKey = "skipWelcomeScreen"
}

struct WelcomeView: View {
    var onStart: () -> Void
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage(WelcomeStorage.skipWelcomeKey) private var skipWelcomeScreen = false
    @State private var dontShowAgain = false

    var body: some View {
        ZStack {
            (isDarkMode ? Color.black : Color(.systemGroupedBackground))
                .ignoresSafeArea()

            VStack(spacing: 0) {
                logoView
                    .padding(.top, 150)
                    .padding(.bottom, 32)

                Text("welcome_title".localized)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.appRed)
                    .padding(.bottom, 20)

                Text("welcome_description".localized)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 36)

                Spacer()

                Button(action: startApp) {
                    Text("welcome_start".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.appRed)
                        .clipShape(Capsule())
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 130)
                .padding(.top, -150)

                Button {
                    dontShowAgain.toggle()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: dontShowAgain ? "checkmark.square.fill" : "square")
                            .font(.title3)
                            .foregroundStyle(dontShowAgain ? Color.appRed : Color.gray)

                        Text("welcome_dont_show_again".localized)
                            .font(.subheadline)
                            .foregroundStyle(.gray)

                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, -10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .id(localizationManager.currentLanguage)
    }

    private func startApp() {
        if dontShowAgain {
            skipWelcomeScreen = true
        }
        onStart()
    }

    private var logoView: some View {
        Image("SitterLogo")
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 160)
    }
}

#Preview {
    WelcomeView(onStart: {})
}
