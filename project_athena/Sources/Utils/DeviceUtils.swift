//
//  UtilsDeviceUtils.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import UIKit
import Darwin

struct DeviceUtils {
    static func deviceName() -> String { UIDevice.current.name }
    static func systemVersion() -> String { UIDevice.current.systemVersion }
    static func getDeviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let data = Data(bytes: &systemInfo.machine, count: Int(MemoryLayout.size(ofValue: systemInfo.machine)))
        let model = String(data: data, encoding: .ascii)?
            .trimmingCharacters(in: .controlCharacters) ?? "N/A"
        return model
    }
    static func batteryStatus() -> String {
            switch state {
                case .charging:  return "En charge"
                case .full:      return "Pleine"
                case .unplugged: return "Sur batterie"
                default:         return "-"
            }
        }
    static func lastBootDateString() -> String {
        let interval = ProcessInfo.processInfo.systemUptime
        let bootDate = Date().addingTimeInterval(-interval)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: bootDate)
    }
}
