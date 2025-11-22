//
//  MetricsGridView.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

struct MetricsGridView: View {
    let cpuFraction: Double
    let ramFraction: Double
    let ramGo: Double
    let storageUsed: Double
    let storageTotal: Double
    let percentUsed: Double
    let batteryLevel: Float
    let batteryState: UIDevice.BatteryState
    let batteryStatusText: String
    
    var body: some View {
        let batteryColor = Formatting.appleBatteryColor(level: batteryLevel, state: batteryState)
        let batteryText = Formatting.batteryStatusText(state: batteryState)
        
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignSystem.spacing12),
                GridItem(.flexible(), spacing: DesignSystem.spacing12)
            ],
            spacing: DesignSystem.spacing12
        ) {
            // CPU
            StatAppleCard(
                icon: "cpu",
                iconBg: Color.blue,
                title: "CPU",
                valueLeft: "",
                valueRight: String(format: "%.0f%%", cpuFraction * 100),
                percent: cpuFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )
            .frame(height: 170)
            
            // RAM
            StatAppleCard(
                icon: "memorychip",
                iconBg: Color.purple,
                title: "RAM",
                valueLeft: String(format: "%.1f / %.1f Go", ramFraction * ramGo, ramGo),
                valueRight: String(format: "%.0f%%", ramFraction * 100),
                percent: ramFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )
            .frame(height: 170)

            // Stockage
            StatAppleCard(
                icon: "internaldrive",
                iconBg: Color.orange,
                title: "Stockage",
                valueLeft: String(format: "%.1f / %.1f Go", storageUsed, storageTotal),
                valueRight: String(format: "%.0f%%", percentUsed * 100),
                percent: percentUsed,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )
            .frame(height: 170)
            
            // Batterie
            StatAppleCard(
                icon: batteryIconName(for: batteryLevel, state: batteryState),
                iconBg: batteryColor,
                title: "Batterie",
                valueLeft: batteryText,
                valueRight: String(format: "%.0f%%", batteryLevel * 100),
                percent: Double(batteryLevel),
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [batteryColor, batteryColor.opacity(0.6)]),
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                caseColor: Color.cardBackground
            )
            .frame(height: 170)
        }
        .padding(.horizontal, 6)
    }
    
    // MARK: - Helper pour l'icône de batterie
    
    private func batteryIconName(for level: Float, state: UIDevice.BatteryState) -> String {
        if state == .charging {
            return "bolt.fill"
        }
        
        if level >= 0.75 {
            return "battery.100percent"
        } else if level >= 0.5 {
            return "battery.75percent"
        } else if level >= 0.25 {
            return "battery.50percent"
        } else {
            return "battery.25percent"
        }
    }
}
