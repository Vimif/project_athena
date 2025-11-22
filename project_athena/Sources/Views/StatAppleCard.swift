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
        VStack(alignment: .leading, spacing: 0) {
            // En-tête (hauteur fixe)
            HStack(spacing: DesignSystem.spacing8) {
                IconContainer(icon: icon, color: iconBg, size: DesignSystem.iconSizeMedium)
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .frame(height: 36)
            
            Spacer()
            
            // Valeur principale (hauteur fixe)
            Text(valueRight)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .monospacedDigit()
                .frame(height: 40)
            
            Spacer()
            
            // Barre de progression (hauteur fixe)
            progressBar
                .frame(height: 6)
            
            Spacer()
            
            // Valeur secondaire (hauteur fixe)
            Text(valueLeft.isEmpty ? " " : valueLeft)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .frame(height: 16)
        }
        .padding(DesignSystem.spacing16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusMedium, style: .continuous)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusMedium, style: .continuous)
                .strokeBorder(Color.cardBorder, lineWidth: 0.5)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var progressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fond
                Capsule()
                    .fill(Color(.tertiarySystemFill))
                
                // Progression
                Capsule()
                    .fill(barGradient)
                    .frame(width: geometry.size.width * CGFloat(max(min(percent, 1), 0)))
                    .shadow(color: iconBg.opacity(0.3), radius: 2, x: 0, y: 1)
            }
        }
    }
}
