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
    // MARK: - Metrics (ajouter ici toutes les fraactions que tu utilises)
    @Published var stats: [SystemStats] = []
    @Published var networkStat: AppNetworkUsage = AppNetworkUsage(sent: 0, received: 0)

    // Pour compatibilité avec toutes les Views
    @Published var ramFraction: Double = 0.0         // Correction !
    @Published var cpuFraction: Double = 0.0
    @Published var batteryLevel: Float = 0.0
    @Published var batteryState: UIDevice.BatteryState = .unknown
    @Published var isWiFi: Bool = false              // Correction !
    @Published var storageFraction: Double = 0.0
    @Published var networkSamples: [NetworkSample] = []

    var timer: Timer?
    
    init() {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.refreshNetwork()
            }
        }
        func refreshNetwork() {
            // Ici, récupère les stats réseau
            let usageNow = getNetworkUsage() // à créer ou à améliorer !
            // (sent/received en octets)

            // Calcule l’évolution entre les deux dernières valeurs
            let lastUsage = self.networkStat
            let download = Double(max(usageNow.received - lastUsage.received, 0))
            let upload = Double(max(usageNow.sent - lastUsage.sent, 0))
            let newSample = NetworkSample(upload: upload, download: download)
            
            // MAJ des samples (max N points pour éviter surcharge)
            var updated = self.networkSamples
            updated.append(newSample)
            if updated.count > 32 { updated.removeFirst() }
            self.networkSamples = updated
            self.networkStat = usageNow
        }
        func getNetworkUsage() -> AppNetworkUsage {
            // À compléter avec récupération bas niveau
            // (cf. code déjà fourni ou adopter les libs system)
            return AppNetworkUsage(
                sent: UInt64.random(in: 1_000_000...2_000_000),
                received: UInt64.random(in: 2_000_000...4_000_000)
            ) // ici, factice pour test !
        }
    // MARK: - Fonctions utilitaires dynamiques (correctes et typées)

    func getTotalDiskSpaceDouble() -> Double {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double {
              return total/1024/1024/1024
        }
        return 0.0
    }

    func getChipModel(model: String) -> String {
        let mapping: [String: String] = [
            "iPhone18,2": "A19 Pro",
            "iPhone18,1": "A18",
            // étend la table si besoin
        ]
        return mapping[model] ?? "N/A"
    }
    func getTotalMemory() -> String {
        let memory = ProcessInfo.processInfo.physicalMemory
        let gb = Double(memory)/1024/1024/1024
        return String(format: "%.1f GB", gb)
    }
    func getTotalDiskSpace() -> String {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
           let total = attrs[.systemSize] as? Double {
            let gb = total/1024/1024/1024
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
        self.ramFraction = SystemMetrics.ramUsedFraction()
        self.cpuFraction = SystemMetrics.cpuUsageFraction()
        self.storageFraction = SystemMetrics.storageFraction()
        self.batteryLevel = UIDevice.current.batteryLevel
        self.batteryState = UIDevice.current.batteryState
    }
    
    func refreshNetworkType() {
        getCurrentNetworkType { type in
            DispatchQueue.main.async {
                self.isWiFi = (type == .wifi)
            }
        }
    }
    
    func getCurrentNetworkType(completion: @escaping (NetworkType) -> Void) {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
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
    
    // MARK: - Stat réseau bas niveau
//    func getNetworkUsage() -> AppNetworkUsage {
//        var sent: UInt64 = 0
//        var received: UInt64 = 0
//        var addrs: UnsafeMutablePointer<ifaddrs>? = nil
//        guard getifaddrs(&addrs) == 0, let firstAddr = addrs else { return AppNetworkUsage(sent: 0, received: 0) }
//        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
//        while ptr != nil {
//            let name = String(cString: ptr!.pointee.ifa_name)
//            if let data = ptr!.pointee.ifa_data {
//                let networkData = data.bindMemory(to: if_data.self, capacity: 1).pointee
//                if name.hasPrefix("en") || name.hasPrefix("pdp_ip") || name.hasPrefix("awdl") {
//                    sent += UInt64(networkData.ifi_obytes)
//                    received += UInt64(networkData.ifi_ibytes)
//                }
//            }
//            ptr = ptr!.pointee.ifa_next
//        }
//        freeifaddrs(addrs)
//        return AppNetworkUsage(sent: sent, received: received)
//    }
}
