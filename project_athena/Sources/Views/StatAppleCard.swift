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
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(iconBg)
                        .frame(width: 30, height: 30)
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                }
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 8)
                    Capsule()
                        .fill(barGradient)
                        .frame(width: geometry.size.width * CGFloat(max(min(percent, 1), 0)), height: 8)
                }
            }
            .frame(height: 8)
            HStack {
                Text(valueLeft)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(valueRight)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.cardBackground))
        .shadow(color: Color.black.opacity(0.08), radius: 7, x: 0, y: 3)
    }
}
