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

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var cpuFraction: Double = 0.0
    @Published var ramFraction: Double = 0.0
    @Published var storageFraction: Double = 0.0
    @Published var totalDiskSpaceGB: Double = 0.0
    @Published var totalDiskSpaceString: String = "N/A"
    @Published var batteryLevel: Float = 1.0
    @Published var batteryState: UIDevice.BatteryState = .unknown
    @Published var networkStat: AppNetworkUsage = AppNetworkUsage(sent: 0, received: 0)
    @Published var networkSamples: [NetworkSample] = []
    @Published var isWiFi: Bool = false
    
    private var timer: Timer?
    private let maxSamples = 32
    private var previousNetworkStat: AppNetworkUsage?
    private var lastUpdateTime: Date = Date()

    var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    init() {
        // Initialiser avec des données de base
        self.networkSamples = Array(repeating: NetworkSample(upload: 0, download: 0), count: maxSamples)
        
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        // Premier refresh immédiat
        Task {
            await self.refreshStats()
            self.refreshNetworkType()
        }
        
        // Démarrer le timer sur le main thread
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshAll()
            }
        }
    }
    
    // MARK: - Refresh combiné
    
    private func refreshAll() async {
        await refreshStats()
        refreshNetwork()
        refreshNetworkType()
        updateWidgetData()
    }
    
    private func refreshNetwork() {
        let currentTime = Date()
        let currentStat = getNetworkUsage()
        
        // Calculer le delta uniquement s'il y a une stat précédente
        if let previous = previousNetworkStat {
            let timeInterval = currentTime.timeIntervalSince(lastUpdateTime)
            
            guard timeInterval > 0 else { return }
            
            // Calculer les différences (protection contre valeurs négatives)
            let sentDelta = currentStat.sent >= previous.sent ? currentStat.sent - previous.sent : 0
            let receivedDelta = currentStat.received >= previous.received ? currentStat.received - previous.received : 0
            
            // Convertir en Ko/s
            let uploadRate = Double(sentDelta) / timeInterval / 1024.0
            let downloadRate = Double(receivedDelta) / timeInterval / 1024.0
            
            // Créer le nouveau sample
            let newSample = NetworkSample(
                upload: max(0, uploadRate),
                download: max(0, downloadRate)
            )
            
            // Mettre à jour le tableau de manière sûre
            var updatedSamples = self.networkSamples
            updatedSamples.append(newSample)
            
            // Garder seulement les N derniers samples
            if updatedSamples.count > maxSamples {
                updatedSamples.removeFirst(updatedSamples.count - maxSamples)
            }
            
            // Mise à jour atomique
            self.networkSamples = updatedSamples
        }
        
        // Sauvegarder pour le prochain cycle
        self.previousNetworkStat = currentStat
        self.networkStat = currentStat
        self.lastUpdateTime = currentTime
    }
    
    private func getNetworkUsage() -> AppNetworkUsage {
        // Implémentation basique avec données simulées
        // À REMPLACER par la vraie implémentation système si disponible
        let baseSent = UInt64.random(in: 1_000_000...5_000_000)
        let baseReceived = UInt64.random(in: 2_000_000...10_000_000)
        
        return AppNetworkUsage(
            sent: baseSent,
            received: baseReceived
        )
    }
    
    // MARK: - Fonctions utilitaires
    
    func getTotalDiskSpaceDouble() -> Double {
        return totalDiskSpaceGB > 0 ? totalDiskSpaceGB : 128.0
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
            "iPhone15,2": "A16 Bionic",
            "iPhone15,1": "A15 Bionic",
            "iPhone14,3": "A15 Bionic",
            "iPhone14,2": "A15 Bionic"
        ]
        return mapping[model] ?? "N/A"
    }
    
    func getTotalMemory() -> String {
        let memory = ProcessInfo.processInfo.physicalMemory
        let gb = Double(memory) / 1024 / 1024 / 1024
        return String(format: "%.1f GB", gb)
    }
    
    func getTotalDiskSpace() -> String {
        return totalDiskSpaceString
    }
    
    func getUptimeString() -> String {
        let uptime = ProcessInfo.processInfo.systemUptime
        let hours = Int(uptime) / 3600
        let minutes = (Int(uptime) % 3600) / 60
        let seconds = Int(uptime) % 60
        return "\(hours)h \(minutes)m \(seconds)s"
    }
    
    // MARK: - Refresh des stats système
    
    private func refreshStats() async {
        let cpu = SystemMetrics.cpuUsageFraction()
        let ram = SystemMetrics.ramUsedFraction()
        let storage = await SystemMetrics.storageInfo()
        let battery = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        
        self.cpuFraction = cpu > 0 ? cpu : 0.12
        self.ramFraction = ram > 0 ? ram : 0.55
        self.storageFraction = storage.usedFraction > 0 ? storage.usedFraction : 0.22
        self.totalDiskSpaceGB = storage.totalGB
        self.totalDiskSpaceString = storage.totalString
        self.batteryLevel = battery >= 0 ? battery : 0.93
        self.batteryState = state
    }
    
    private func refreshNetworkType() {
        getCurrentNetworkType { [weak self] type in
            DispatchQueue.main.async {
                self?.isWiFi = (type == .wifi)
            }
        }
    }
    
    func getCurrentNetworkType(completion: @escaping (NetworkType) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor.\(UUID().uuidString)")
        
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
    // MARK: - Widget Data Update

    private func updateWidgetData() {
        let widgetData = WidgetData(
            cpuUsage: cpuFraction,
            ramUsage: ramFraction,
            storageUsage: storageFraction,
            batteryLevel: batteryLevel,
            batteryState: batteryStateString(batteryState),
            networkDownload: networkSamples.last?.download ?? 0,
            networkUpload: networkSamples.last?.upload ?? 0,
            isWiFi: isWiFi,
            timestamp: Date()
        )
        
        WidgetDataService.shared.saveWidgetData(widgetData)
    }

    private func batteryStateString(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "charging"
        case .full: return "full"
        case .unplugged: return "unplugged"
        default: return "unknown"
        }
    }
}
