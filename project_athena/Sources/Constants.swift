//
//  Constants.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

// MARK: - Design System Colors

extension Color {
    static let cardBackground = Color(.secondarySystemBackground)
    static let cardBorder = Color(.separator).opacity(0.3)
    static let graphBackground = Color(.secondarySystemGroupedBackground)
    static let accentBlue = Color(.systemBlue)
    static let accentGreen = Color(.systemGreen)
}

// MARK: - Design System Constants

struct DesignSystem {
    // Spacing
    static let spacing4: CGFloat = 4
    static let spacing8: CGFloat = 8
    static let spacing12: CGFloat = 12
    static let spacing16: CGFloat = 16
    static let spacing20: CGFloat = 20
    static let spacing24: CGFloat = 24
    
    // Corner Radius
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 20
    
    // Icon Sizes
    static let iconSizeSmall: CGFloat = 28
    static let iconSizeMedium: CGFloat = 36
    static let iconSizeLarge: CGFloat = 56
    
    // Shadows
    static func cardShadow() -> some View {
        EmptyView()
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
    
    static func lightShadow() -> some View {
        EmptyView()
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Reusable Card Container

struct CardContainer<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = 20, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge, style: .continuous)
                    .fill(Color.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.cornerRadiusLarge, style: .continuous)
                    .strokeBorder(Color.cardBorder, lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Icon Container

struct IconContainer: View {
    let icon: String
    let color: Color
    let size: CGFloat
    
    init(icon: String, color: Color, size: CGFloat = DesignSystem.iconSizeMedium) {
        self.icon = icon
        self.color = color
        self.size = size
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(color.opacity(0.15))
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.5, weight: .semibold))
                .foregroundColor(color)
        }
    }
}
