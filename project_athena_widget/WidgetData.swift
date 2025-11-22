//
//  WidgetData.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 22/11/2025.
//

import Foundation

struct WidgetData: Codable {
    let cpuUsage: Double
    let ramUsage: Double
    let storageUsage: Double
    let batteryLevel: Float
    let batteryState: String
    let networkDownload: Double
    let networkUpload: Double
    let isWiFi: Bool
    let timestamp: Date
    
    static var placeholder: WidgetData {
        WidgetData(
            cpuUsage: 0.35,
            ramUsage: 0.62,
            storageUsage: 0.48,
            batteryLevel: 0.85,
            batteryState: "unplugged",
            networkDownload: 1250.0,
            networkUpload: 450.0,
            isWiFi: true,
            timestamp: Date()
        )
    }
}
