//
//  SystemMetrics.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import Foundation
import UIKit

struct StorageInfo {
    let totalGB: Double
    let usedGB: Double
    let usedFraction: Double
    let totalString: String
}

struct SystemMetrics {
    static func ramUsedFraction() -> Double {
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        // iOS ne donne pas l'info exacte publiquement
        // Pour démo : retourne une fraction approximative
        let used = total * 0.67 // À remplacer par API réelle si disponible
        return total > 0 ? used / total : 0.0
    }
    
    static func cpuUsageFraction() -> Double {
        // iOS ne donne pas accès direct au CPU usage
        // Pour démo : retourne une valeur aléatoire
        return Double.random(in: 0.01...0.15) // À remplacer par API réelle
    }
    
    static func storageFraction() async -> Double {
        return await storageInfo().usedFraction
    }

    static func storageInfo() async -> StorageInfo {
        return await Task.detached(priority: .utility) {
            guard let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
                  let total = attrs[.systemSize] as? Double,
                  let free = attrs[.systemFreeSize] as? Double else {
                return StorageInfo(totalGB: 128.0, usedGB: 0.0, usedFraction: 0.0, totalString: "N/A")
            }

            let used = total - free
            let fraction = total > 0 ? used / total : 0.0
            let totalGB = total / 1024 / 1024 / 1024
            let usedGB = used / 1024 / 1024 / 1024
            let totalString = String(format: "%.1f GB", totalGB)

            return StorageInfo(
                totalGB: totalGB,
                usedGB: usedGB,
                usedFraction: fraction,
                totalString: totalString
            )
        }.value
    }
}
