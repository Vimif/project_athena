//
//  WidgetDataService.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 22/11/2025.
//

import Foundation
import WidgetKit

class WidgetDataService {
    static let shared = WidgetDataService()
    
    private let appGroupIdentifier = "group.com.tonnom.project-athena"
    private let widgetDataKey = "widgetData"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // Sauvegarder les données pour le widget
    func saveWidgetData(_ data: WidgetData) {
        guard let userDefaults = userDefaults else { return }
        
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: widgetDataKey)
            userDefaults.synchronize()
            
            // Demander au widget de se rafraîchir
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    // Charger les données du widget
    func loadWidgetData() -> WidgetData? {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: widgetDataKey),
              let decoded = try? JSONDecoder().decode(WidgetData.self, from: data) else {
            return nil
        }
        return decoded
    }
}
