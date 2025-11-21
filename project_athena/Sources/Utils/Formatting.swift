//
//  Formatting.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

struct Formatting {
    
    /// Donne la couleur à utiliser pour la barre/bouton batterie selon niveau et état
    static func appleBatteryColor(level: Float, state: UIDevice.BatteryState) -> Color {
        switch state {
        case .charging:
            return Color.green
        case .full:
            return Color.blue
        case .unplugged:
            return level < 0.2 ? Color.red : Color.yellow
        default:
            return Color.gray
        }
    }
    
    /// Retourne un texte d’état de batterie en français selon l’état
    static func batteryStatusText(state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging:
            return "En charge"
        case .full:
            return "Chargée"
        case .unplugged:
            return "Sur batterie"
        default:
            return "État inconnu"
        }
    }
    
    /// Affichage humain du nombre d’octets sous forme Go
    static func formatBytes(_ value: Double) -> String {
        String(format: "%.1f GB", value / 1024 / 1024 / 1024)
    }
    
    /// Formatage classique en pourcentage (Double [0...1])
    static func formatPercent(_ value: Double) -> String {
        String(format: "%.1f%%", value * 100)
    }
    
    /// Formatage pour les Mo
    static func formatMegaBytes(_ value: Double) -> String {
        String(format: "%.1f MB", value / 1024 / 1024)
    }
    
    /// Formatage simple pour durée (seconds to H:M:S)
    static func formatDuration(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return "\(hours)h \(minutes)m \(secs)s"
    }
}
