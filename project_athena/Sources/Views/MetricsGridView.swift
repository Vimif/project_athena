//
//  MetricsGridView.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

let ramGo = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024
let ramUsedGo = ramFraction * ramGo
let storageTuple = LocalSystemMetrics.storageInfo()
let storageTotal = storageTuple?.total ?? 1.0
let storageUsed = storageTuple != nil ? storageTuple!.total - storageTuple!.free : 0.0
let percentUsed = (storageTotal > 0) ? (storageUsed / storageTotal) : 0

struct MetricsGridView: View {
    let stats: SystemStats
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatAppleCard(
                icon: "cpu",
                iconColor: .white,
                iconBg: Color.blue.opacity(0.85),
                title: "CPU",
                valueLeft: "Syst: 3.2%",
                valueRight: String(format: "%.1f%%", cpuFraction * 100),
                percent: cpuFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.cyan]),
                    startPoint: .leading, endPoint: .trailing
                ),
                caseColor: .cardBackground) // CPU
            StatAppleCard(
                icon: "memorychip",
                iconColor: .white,
                iconBg: Color.cyan.opacity(0.85),
                title: "RAM",
                valueLeft: String(format: "%.2f Go / %.2f Go", ramUsedGo, ramGo),
                valueRight: String(format: "%.1f%%", ramFraction * 100),
                percent: ramFraction,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.cyan, Color.blue]),
                    startPoint: .leading, endPoint: .trailing
                ),
                caseColor: .cardBackground) // RAM
            StatAppleCard(
                icon: "internaldrive",
                iconColor: .white,
                iconBg: Color.purple.opacity(0.85),
                title: "Stockage",
                valueLeft: String(format: "%.1f G/%.1f G", storageUsed, storageTotal),
                valueRight: String(format: "%.1f%%", percentUsed * 100),
                percent: percentUsed,
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .leading, endPoint: .trailing
                ),
                caseColor: .cardBackground) // Stockage
            StatAppleCard(
                icon: "battery.100",
                iconColor: .white,
                iconBg: appleBatteryColor(level: batteryLevel, state: batteryState),
                title: "Batterie",
                valueLeft: String(format: "%.0f%%", max(0, min(1, batteryLevel)) * 100),
                valueRight: "",
                percent: Double(max(0, min(batteryLevel, 1))),
                barGradient: LinearGradient(
                    gradient: Gradient(colors: [
                        appleBatteryColor(level: batteryLevel, state: batteryState),
                        Color(.systemGray3)
                    ]),
                    startPoint: .leading, endPoint: .trailing
                ),
                valueStatus: batteryStatusText(batteryState),
                caseColor: .cardBackground) // Batterie
        }
    }
}
