//
//  LogoView.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-12-22.
//

import SwiftUI
#if canImport(Pow)
import Pow
#endif
import AVFoundation

struct LogoView: View {
    @State private var showLogo = false
    @State private var startExit = false
    @State private var opacity = 1.0
    @State private var backgroundOpacity = 1.0
    @State private var audioPlayer: AVAudioPlayer?
    let onAnimationComplete: () -> Void
    
    private var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    @ViewBuilder
    private var logoImage: some View {
        #if canImport(Pow)
        Image("AbaShelAriLogo")
            .resizable()
            .scaledToFit()
            .frame(width: isIPhone ? 350 : 700)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(.white)
            .transition(
                .identity
                    .animation(.linear(duration: 2.5).delay(2.5))
                    .combined(
                        with: .movingParts.glare
                    )
            )
        #else
        Image("AbaShelAriLogo")
            .resizable()
            .scaledToFit()
            .frame(width: isIPhone ? 350 : 700)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .foregroundColor(.white)
            .transition(.opacity.animation(.linear(duration: 2.5).delay(2.5)))
        #endif
    }
    
    private func playLogoSound() {
        if let path = Bundle.main.path(forResource: "logo3", ofType: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                audioPlayer?.play()
            } catch {
                print("Could not play sound file: \(error)")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Background - now with its own opacity
            Color.white
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Logo text
            if showLogo {
                logoImage
                    .opacity(opacity)
            }
        }
        
        .onAppear {
            // Delay the start of the logo animation
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                withAnimation {
                    showLogo = true
                    // Play logo sound when the logo appears
                    playLogoSound()
                }
            }
            
            // Duration of logo display
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // First fade out the logo
                withAnimation(.easeOut(duration: 1)) {
                    opacity = 0
                }
                
                // Start fading out the background and trigger main app
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    // Trigger main app to appear
                    onAnimationComplete()
                    
                    // Fade out background slowly
                    withAnimation(.easeOut(duration: 1)) {
                        backgroundOpacity = 0
                    }
                }
            }
        }
    }
}

#Preview {
    LogoView {
        print("Animation complete")
    }
}

