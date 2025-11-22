//
//  SystemMetrics.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import Foundation
import UIKit

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
    
    static func storageFraction() -> Double {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double,
           let free = attrs[.systemFreeSize] as? Double {
            let used = total - free
            return total > 0 ? used / total : 0.0
        }
        return 0.0
    }
}
