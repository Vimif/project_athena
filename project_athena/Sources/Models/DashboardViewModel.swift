//
//  DashboardViewModel.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import Foundation
import Network
import UIKit
import Combine

enum NetworkType {
    case wifi, cellular, none
}

class DashboardViewModel: ObservableObject {
    @Published var cpuFraction: Double = 0.0
    @Published var ramFraction: Double = 0.0
    @Published var storageFraction: Double = 0.0
    @Published var batteryLevel: Float = 1.0
    @Published var batteryState: UIDevice.BatteryState = .unknown
    @Published var networkStat: AppNetworkUsage = AppNetworkUsage(sent: 0, received: 0)
    @Published var networkSamples: [NetworkSample] = []
    @Published var isWiFi: Bool = false
    
    var timer: Timer?
    private var lastNetworkUpdate: Date = Date()

    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    init() {
        // Initialiser avec des données factices pour le graphique
        self.networkSamples = (0..<32).map { _ in
            NetworkSample(
                upload: Double.random(in: 300...1200),
                download: Double.random(in: 600...2400)
            )
        }

        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Premier refresh
        refreshStats()
        refreshNetworkType()
        
        // Initialiser networkStat avec des valeurs de départ
        self.networkStat = getNetworkUsage()
        
        // Timer pour les mises à jour régulières
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.refreshStats()
            self?.refreshNetwork()
            self?.refreshNetworkType()
        }
    }
    
    func refreshNetwork() {
        // Mesurer le temps écoulé depuis la dernière mise à jour
        let now = Date()
        let timeInterval = now.timeIntervalSince(lastNetworkUpdate)
        
        guard timeInterval > 0 else { return }
        
        // Récupérer les nouvelles stats réseau
        let usageNow = getNetworkUsage()
        
        // Calculer la différence (en octets)
        let downloadBytes = usageNow.received > networkStat.received
            ? Double(usageNow.received - networkStat.received)
            : 0.0
        let uploadBytes = usageNow.sent > networkStat.sent
            ? Double(usageNow.sent - networkStat.sent)
            : 0.0
        
        // Convertir en octets par seconde, puis en Ko/s
        let downloadRate = (downloadBytes / timeInterval) / 1024
        let uploadRate = (uploadBytes / timeInterval) / 1024
        
        // Créer un nouveau sample avec les taux calculés
        let newSample = NetworkSample(
            upload: max(uploadRate, 0),
            download: max(downloadRate, 0)
        )
        
        // Mettre à jour les samples (garder les 32 derniers points)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var updated = self.networkSamples
            updated.append(newSample)
            if updated.count > 32 {
                updated.removeFirst()
            }
            
            self.networkSamples = updated
            self.networkStat = usageNow
            self.lastNetworkUpdate = now
        }
    }
    
    func getNetworkUsage() -> AppNetworkUsage {
        // En mode Preview, retourner des données factices
        if isPreview {
            return AppNetworkUsage(
                sent: UInt64.random(in: 1_000_000...2_000_000),
                received: UInt64.random(in: 2_000_000...4_000_000)
            )
        }
        
        // Pour l'instant, données factices aussi en prod
        // À remplacer par une vraie implémentation si besoin
        return AppNetworkUsage(
            sent: UInt64.random(in: 1_000_000...2_000_000),
            received: UInt64.random(in: 2_000_000...4_000_000)
        )
    }
    
    // MARK: - Fonctions utilitaires dynamiques

    func getTotalDiskSpaceDouble() -> Double {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double {
            return total / 1024 / 1024 / 1024
        }
        return 0.0
    }

    func getChipModel(model: String) -> String {
        let mapping: [String: String] = [
            "iPhone18,2": "A19 Pro",
            "iPhone18,1": "A18",
            "iPhone17,2": "A17 Pro",
            "iPhone17,1": "A17",
            "iPhone16,2": "A16 Bionic",
            "iPhone16,1": "A16 Bionic",
            "iPhone15,3": "A16 Bionic",
            "iPhone15,2": "A16 Bionic"
        ]
        return mapping[model] ?? "N/A"
    }
    
    func getTotalMemory() -> String {
        let memory = ProcessInfo.processInfo.physicalMemory
        let gb = Double(memory) / 1024 / 1024 / 1024
        return String(format: "%.1f GB", gb)
    }
    
    func getTotalDiskSpace() -> String {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double {
            let gb = total / 1024 / 1024 / 1024
            return String(format: "%.1f GB", gb)
        }
        return "N/A"
    }
    
    func getUptimeString() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        return "\(hours)h \(minutes)m \(seconds)s"
    }
    
    // MARK: - Refresh/Mise à jour background
    
    func refreshStats() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let cpu = SystemMetrics.cpuUsageFraction()
            let ram = SystemMetrics.ramUsedFraction()
            let stor = SystemMetrics.storageFraction()
            let battery = UIDevice.current.batteryLevel
            let state = UIDevice.current.batteryState
            
            self.cpuFraction = cpu > 0 ? cpu : 0.12
            self.ramFraction = ram > 0 ? ram : 0.55
            self.storageFraction = stor > 0 ? stor : 0.22
            self.batteryLevel = battery >= 0 ? battery : 0.93
            self.batteryState = state
        }
    }
    
    func refreshNetworkType() {
        getCurrentNetworkType { [weak self] type in
            DispatchQueue.main.async {
                self?.isWiFi = (type == .wifi)
            }
        }
    }
    
    func getCurrentNetworkType(completion: @escaping (NetworkType) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        
        monitor.pathUpdateHandler = { path in
            defer { monitor.cancel() }
            
            if path.usesInterfaceType(.wifi) {
                completion(.wifi)
            } else if path.usesInterfaceType(.cellular) {
                completion(.cellular)
            } else {
                completion(.none)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}
