//
//  ModelsSystemMetrics.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import Foundation
import UIKit

struct SystemMetrics {
    static func ramUsedFraction() -> Double {
        // iOS : méthode pour RAM utilisée / totale
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        // Utilisation approximative (iOS ne donne pas l'info exacte publique, mais via report sur simul/machine, ou via host_statistics sur Mac)
        // Pour démo/config pro : retourne la fraction virtuelle
        let used = total * 0.67 // <--- À remplacer par API vraie si dispo
        return total > 0 ? used/total : 0.0
    }
    static func cpuUsageFraction() -> Double {
        // iOS ne donne pas accès direct, Mac oui (via host_processor_info)
        // Pour l'instant, retourne une valeur random ou stable :
        return Double.random(in: 0.01...0.15) // à remplacer par API vraie
    }
    static func storageFraction() -> Double {
        // Stockage utilisé / total
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double,
           let free = attrs[.systemFreeSize] as? Double {
            let used = total - free
            return total > 0 ? used / total : 0.0
        }
        return 0.0
    }
}
