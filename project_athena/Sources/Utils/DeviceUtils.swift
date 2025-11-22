//
//  DeviceUtils.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import UIKit

struct DeviceUtils {
    static func deviceName() -> String {
        UIDevice.current.name
    }
    
    static func systemVersion() -> String {
        UIDevice.current.systemVersion
    }
    
    static func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let data = Data(bytes: &systemInfo.machine, count: Int(MemoryLayout.size(ofValue: systemInfo.machine)))
        return String(data: data, encoding: .ascii)?
            .trimmingCharacters(in: .controlCharacters) ?? "N/A"
    }
    
    static func batteryStatus() -> String {
        "Sur batterie"
    }
    
    static func lastBootDateString() -> String {
        let interval = ProcessInfo.processInfo.systemUptime
        let bootDate = Date().addingTimeInterval(-interval)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: bootDate)
    }
}
