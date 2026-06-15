//
//  PaymentFormatting.swift
//  SitterPay
//

import Foundation

enum PaymentFormat {
    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.decimalSeparator = "."
        formatter.usesGroupingSeparator = true
        return formatter
    }()
    
    /// Formats a payment amount as `1,400.00`
    static func amount(_ value: Double) -> String {
        amountFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
    
    /// Formats with currency symbol prefix, e.g. `$1,400.00`
    static func currency(_ value: Double, symbol: String) -> String {
        "\(symbol)\(amount(value))"
    }
}

enum DurationFormat {
    /// Formats a duration as `1h 30m`, `1h 0m`, `45m`, or `0m`
    static func compact(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        if minutes > 0 {
            return "\(minutes)m"
        }
        return "0m"
    }
}

extension String {
    /// Parses payment strings that may include grouping commas, e.g. `1,400.00`
    var paymentAmountValue: Double? {
        Double(replacingOccurrences(of: ",", with: ""))
    }
    
    /// Keeps only characters valid in a payment input field
    func filteringPaymentInput() -> String {
        filter { "0123456789.,".contains($0) }
    }
}
