import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = DashboardViewModel()

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
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
                    
                    // Grille de métriques
                    MetricsGridView(
                        cpuFraction: viewModel.cpuFraction,
                        ramFraction: viewModel.ramFraction,
                        ramGo: Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024,
                        storageUsed: viewModel.storageFraction * viewModel.getTotalDiskSpaceDouble(),
                        storageTotal: viewModel.getTotalDiskSpaceDouble(),
                        percentUsed: viewModel.storageFraction,
                        batteryLevel: viewModel.batteryLevel,
                        batteryState: viewModel.batteryState,
                        batteryStatusText: viewModel.batteryState == .charging ? "En charge" : "Sur batterie"
                    )

                    // Panneau réseau
                    NetworkPanelCard(
                        netPoints: viewModel.networkSamples,
                        totalDownload: Double(viewModel.networkStat.received) / 1024 / 1024,
                        totalUpload: Double(viewModel.networkStat.sent) / 1024 / 1024,
                        isWiFi: viewModel.isWiFi
                    )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Tableau de bord")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
