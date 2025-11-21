import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = DashboardViewModel() // Ton ViewModel central

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Carte infos device
                    DeviceInfoCard(
                        deviceName: DeviceUtils.deviceName(),
                        iosVersion: DeviceUtils.systemVersion(),
                        model: DeviceUtils.deviceModel(),
                        chip: viewModel.getChipModel(model: DeviceUtils.deviceModel()),
                        memory: viewModel.getTotalMemory(),
                        storage: viewModel.getTotalDiskSpace(),
                        uptime: viewModel.getUptimeString(),
                        lastReboot: DeviceUtils.lastBootDateString()
                    )
                    
                    // Grille stat CPU/RAM/Stockage/Batterie
                    MetricsGridView(
                        cpuFraction: viewModel.cpuFraction,
                        ramFraction: viewModel.ramFraction,
                        ramGo: Double(ProcessInfo.processInfo.physicalMemory)/1024/1024/1024,
                        storageUsed: $viewModel.storageFraction * $viewModel.getTotalDiskSpaceDouble, // Adapte getTotalDiskSpaceDouble()
                        storageTotal: viewModel.getTotalDiskSpaceDouble(),
                        percentUsed: $viewModel.storageFraction,
                        batteryLevel: viewModel.batteryLevel,
                        batteryState: viewModel.batteryState,
                        batteryStatusText: viewModel.batteryState == .charging ? "En charge" : "Sur batterie",
                        appleBatteryColor: viewModel.batteryState == .charging ? Color.green : Color.blue
                    )
                    
                    // Carte réseau
                    NetworkPanelCard(
                        netPoints: viewModel.networkSamples,
                        totalDownload: Double(viewModel.networkStat.received)/1024/1024, // conversion bytes→Mo
                        totalUpload: Double(viewModel.networkStat.sent)/1024/1024,
                        isWiFi: viewModel.isWiFi
                    )
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tableau de bord")
        }
        .preferredColorScheme(.dark)
    }
}

Preview {
    ContentView()
}
// Optionnel : méthode utilitaire pour stockage en Go dans ViewModel
// func getTotalDiskSpaceDouble() -> Double { /* ... retourne le total en Go */ }
