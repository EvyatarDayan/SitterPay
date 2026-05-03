//
//  BabysitterManager.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import Foundation
import SwiftUI

class BabysitterManager: ObservableObject {
    @Published var babysitters: [Babysitter] = []
    
    private let allBabysittersKey = "AllBabysitters"
    
    init() {
        loadBabysitters()
        
        // Observe babysitters changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(babysittersDidChange),
            name: NSNotification.Name("BabysittersDidChange"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func babysittersDidChange() {
        loadBabysitters()
    }
    
    func addBabysitter(_ babysitter: Babysitter) {
        // Load all babysitters, add new one, save all
        var allBabysitters = loadAllBabysitters()
        allBabysitters.append(babysitter)
        saveAllBabysitters(allBabysitters)
        
        // Reload babysitters
        loadBabysitters()
        
        // Notify that babysitters changed
        NotificationCenter.default.post(name: NSNotification.Name("BabysittersDidChange"), object: nil)
    }
    
    func updateBabysitter(_ babysitter: Babysitter) {
        var allBabysitters = loadAllBabysitters()
        if let index = allBabysitters.firstIndex(where: { $0.id == babysitter.id }) {
            allBabysitters[index] = babysitter
            saveAllBabysitters(allBabysitters)
            loadBabysitters()
            
            // Notify that babysitters changed
            NotificationCenter.default.post(name: NSNotification.Name("BabysittersDidChange"), object: nil)
        }
    }
    
    func deleteBabysitter(_ babysitter: Babysitter) {
        var allBabysitters = loadAllBabysitters()
        allBabysitters.removeAll { $0.id == babysitter.id }
        saveAllBabysitters(allBabysitters)
        loadBabysitters()
        
        // Notify that babysitters changed
        NotificationCenter.default.post(name: NSNotification.Name("BabysittersDidChange"), object: nil)
    }
    
    func deleteBabysittersForUser(_ userId: UUID) {
        var allBabysitters = loadAllBabysitters()
        allBabysitters.removeAll { $0.userId == userId }
        saveAllBabysitters(allBabysitters)
        loadBabysitters()
    }
    
    private func saveAllBabysitters(_ babysitters: [Babysitter]) {
        if let encoded = try? JSONEncoder().encode(babysitters) {
            UserDefaults.standard.set(encoded, forKey: allBabysittersKey)
        }
    }
    
    private func loadAllBabysitters() -> [Babysitter] {
        if let data = UserDefaults.standard.data(forKey: allBabysittersKey),
           let decoded = try? JSONDecoder().decode([Babysitter].self, from: data) {
            return decoded
        }
        return []
    }
    
    func loadBabysitters() {
        let allBabysitters = loadAllBabysitters()
        babysitters = allBabysitters
    }
}

