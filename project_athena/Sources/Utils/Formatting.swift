//
//  Formatting.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import Foundation

struct Formatting {
    static func formatBytes(_ value: Double) -> String {
        String(format: "%.1f GB", value / 1024 / 1024 / 1024)
    }
    static func formatPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
    let color = BatteryUtils.appleBatteryColor(level: batteryLevel, state: batteryState)
    let statusText = BatteryUtils.batteryStatusText(state: batteryState)
}
