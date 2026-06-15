//
//  CardStyle.swift
//  SitterPay
//

import SwiftUI

extension Color {
    static var cardBackground: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : UIColor.white
        })
    }
}

extension View {
    func calcCardStyle() -> some View {
        background(Color.cardBackground)
            .cornerRadius(16)
    }
    
    func cardFieldBackground() -> some View {
        padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

struct CardSectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}

extension EdgeInsets {
    static let cardListRow = EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)
}
