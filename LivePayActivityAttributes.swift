//
//  LivePayActivityAttributes.swift
//  SitterPay
//
//  Created by EVYATAR DAYAN on 2025-11-29.
//

import Foundation
import ActivityKit

struct LivePayActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var currentPay: Double
        var duration: TimeInterval
        var babysitterName: String
        var currencySymbol: String
    }
    
    var startTime: Date
    var hourlyRate: Double
    var otherPays: Double
}
