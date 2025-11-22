//
//  StatAppleCard.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

struct StatAppleCard: View {
    let icon: String
    let iconBg: Color
    let title: String
    let valueLeft: String
    let valueRight: String
    let percent: Double
    let barGradient: LinearGradient
    let caseColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // En-tête avec icône et titre
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconBg.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconBg)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Valeur principale (droite) en grand
            Text(valueRight)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
            
            // Barre de progression avec gradient
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Fond de la barre
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)
                    
                    // Barre de progression
                    Capsule()
                        .fill(barGradient)
                        .frame(
                            width: geometry.size.width * CGFloat(max(min(percent, 1), 0)),
                            height: 6
                        )
                        .shadow(color: iconBg.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            .frame(height: 6)
            
            // Valeur secondaire (gauche)
            if !valueLeft.isEmpty {
                Text(valueLeft)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.3), lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}
