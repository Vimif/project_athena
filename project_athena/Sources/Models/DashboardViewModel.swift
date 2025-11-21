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
    
    // MARK: - Fonctions utilitaires dynamiques (correctes et typées)
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
        DispatchQueue.global().async {
            // Remplace LocalSystemMetrics par tes Utils ! (SystemMetrics.swift)
            let ram = min(max(SystemMetrics.ramUsedFraction(), 0), 1)
            let cpu = min(max(SystemMetrics.cpuUsageFraction(), 0), 1)
            let level = UIDevice.current.batteryLevel
            let state = UIDevice.current.batteryState
            DispatchQueue.main.async {
                self.ramFraction = ram
                self.cpuFraction = cpu
                self.batteryLevel = level
                self.batteryState = state
            }
        }
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
    
    // MARK: - Stat réseau bas niveau
    func getNetworkUsage() -> AppNetworkUsage {
        var sent: UInt64 = 0
        var received: UInt64 = 0
        var addrs: UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&addrs) == 0, let firstAddr = addrs else { return AppNetworkUsage(sent: 0, received: 0) }
        var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
        while ptr != nil {
            let name = String(cString: ptr!.pointee.ifa_name)
            if let data = ptr!.pointee.ifa_data {
                let networkData = data.bindMemory(to: if_data.self, capacity: 1).pointee
                if name.hasPrefix("en") || name.hasPrefix("pdp_ip") || name.hasPrefix("awdl") {
                    sent += UInt64(networkData.ifi_obytes)
                    received += UInt64(networkData.ifi_ibytes)
                }
            }
            ptr = ptr!.pointee.ifa_next
        }
        freeifaddrs(addrs)
        return AppNetworkUsage(sent: sent, received: received)
    }

    // Appelle refresh dans ton init ou cycle background
    init() {
        refreshStats()
        refreshNetworkType()
    }
}
