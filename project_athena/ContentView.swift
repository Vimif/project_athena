import SwiftUI
import Combine
import Foundation
import Darwin

/// Carte widget Apple : info ressource + barre + stats (recommandations iOS/iPhone)
struct StatAppleCard: View {
    let icon: String         // SF Symbol, ex: "internaldrive"
    let iconColor: Color     // couleur symbole
    let iconBg: Color        // fond carré icône
    let title: String        // titre, ex: "Stockage"
    let valueLeft: String    // ex: "207.8 G/511.4 G"
    let valueRight: String   // ex: "40.6%"
    let percent: Double      // 0...1
    let barGradient: LinearGradient

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            // Icône + titre côte à côte, compacts
            HStack(spacing: 7) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(iconBg)
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18)
                        .foregroundColor(iconColor)
                }
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .font(.title2)
                Spacer()
            }
            // Barre de progression fine
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray4))
                        .frame(height: 8)
                    Capsule()
                        .fill(barGradient)
                        .frame(width: geometry.size.width * CGFloat(max(min(percent,1),0)), height: 8)
                }
            }
            .frame(height: 8)
            // Stat principale
            HStack(alignment: .firstTextBaseline) {
                Text(valueLeft)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .font(.title2)
                Spacer()
                if !valueRight.isEmpty {
                    Text(valueRight)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .font(.title2)
                } else {
                    Text("  ").font(.system(size: 11)).foregroundColor(.clear)
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 11)
        .padding(.horizontal, 13)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.tertiarySystemBackground))
        )
        .frame(minWidth: 120, maxWidth: .infinity, minHeight: 74, maxHeight: 92)
    }
}

struct NetPanelCompact: View {
    let points: [NetworkSample]
    let lastDownload: Double
    let lastUpload: Double

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.green)
                    .font(.system(size: 15, weight: .semibold))
                Text("↓ \(String(format: "%.1f", lastDownload/1024)) MB/s")
                    .foregroundColor(.blue)
                    .font(.footnote)
                Text("↑ \(String(format: "%.1f", lastUpload/1024)) MB/s")
                    .foregroundColor(.green)
                    .font(.footnote)
                Spacer()
            }
            .padding(.bottom, -2)
            NetGraphCompact(points: points, maxPoints: 36, window: 7)
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 3).fill(Color.green).frame(width: 10, height: 5)
                Text("Upload").foregroundColor(.green).font(.caption2)
                RoundedRectangle(cornerRadius: 3).fill(Color.blue).frame(width: 10, height: 5)
                Text("Download").foregroundColor(.blue).font(.caption2)
                Spacer()
            }
        }
        .padding(.all, 10)
        .background(RoundedRectangle(cornerRadius: 13).fill(Color(.tertiarySystemBackground)))
    }
}


// --------- Composant Graphique Réseau ---------
struct NetGraphCompact: View {
    let points: [NetworkSample]
    let maxPoints: Int
    let window: Int

    let downloadColor: Color = .blue
    let uploadColor: Color = .green

    func rollingAverage(_ values: [Double]) -> [Double] {
        guard values.count > window else { return values }
        var avg: [Double] = []
        for i in 0..<values.count {
            let lower = max(0, i-window/2)
            let upper = min(values.count-1, i+window/2)
            let slice = Array(values[lower...upper])
            avg.append(slice.reduce(0,+) / Double(slice.count))
        }
        return avg
    }

    func catmullRomPath(values: [Double], size: CGSize) -> Path? {
        let total = min(values.count, maxPoints)
        guard total > 3 else { return nil }
        let valmax = max(values.max() ?? 128, 128)
        let stepX = size.width / CGFloat(max(total-1,1))
        var pts: [CGPoint] = []
        for i in 0..<total {
            let x = CGFloat(i) * stepX
            let y = size.height - CGFloat(values[values.count-total+i] / valmax) * size.height
            pts.append(CGPoint(x: x, y: y))
        }
        var path = Path()
        path.move(to: pts[0])
        for i in 0..<pts.count-1 {
            let p0 = i>0 ? pts[i-1] : pts[i]
            let p1 = pts[i]
            let p2 = pts[i+1]
            let p3 = (i+2 < pts.count) ? pts[i+2] : p2
            for t in stride(from: 0, through: 1, by: 0.14) {
                let tt = CGFloat(t)
                let x = 0.5 * ((2*p1.x) +
                    (-p0.x + p2.x)*tt +
                    (2*p0.x - 5*p1.x + 4*p2.x - p3.x) * tt*tt +
                    (-p0.x + 3*p1.x - 3*p2.x + p3.x) * tt*tt*tt)
                let y = 0.5 * ((2*p1.y) +
                    (-p0.y + p2.y)*tt +
                    (2*p0.y - 5*p1.y + 4*p2.y - p3.y) * tt*tt +
                    (-p0.y + 3*p1.y - 3*p2.y + p3.y) * tt*tt*tt)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }

    var body: some View {
        GeometryReader { geo in
            let smoothDownload = rollingAverage(points.map { $0.download })
            let smoothUpload = rollingAverage(points.map { $0.upload })
            ZStack {
                // Graduation simple (128, 64)
                ForEach([64, 128], id: \.self) { val in
                    let y = geo.size.height - geo.size.height * CGFloat(Double(val) / max(smoothDownload.max() ?? 128, 128))
                    Rectangle().fill(Color.gray.opacity(0.19))
                        .frame(height: 1)
                        .position(x: geo.size.width / 2, y: y)
                }
                // Courbes
                if let dpath = catmullRomPath(values: smoothDownload, size: geo.size) {
                    dpath.stroke(downloadColor, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                        .animation(.easeInOut(duration: 0.32), value: points)
                }
                if let upath = catmullRomPath(values: smoothUpload, size: geo.size) {
                    upath.stroke(uploadColor, style: StrokeStyle(lineWidth: 1.7, lineCap: .round))
                        .animation(.easeInOut(duration: 0.32), value: points)
                }
            }
        }
        .frame(height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 11, style: .continuous))
    }
}



// --------- Modèle réseau ---------
struct AppNetworkUsage {
    var sent: UInt32 = 0
    var received: UInt32 = 0
}
struct NetworkSample: Equatable {
    let upload: Double // KB/s
    let download: Double // KB/s
}
func getNetworkUsage() -> AppNetworkUsage {
    var sent: UInt32 = 0
    var received: UInt32 = 0
    var addrs: UnsafeMutablePointer<ifaddrs>? = nil
    guard getifaddrs(&addrs) == 0, let firstAddr = addrs else { return AppNetworkUsage(sent: 0, received: 0) }
    var ptr: UnsafeMutablePointer<ifaddrs>? = firstAddr
    while ptr != nil {
        let name = String(cString: ptr!.pointee.ifa_name)
        if let data = ptr!.pointee.ifa_data {
            let networkData = data.bindMemory(to: if_data.self, capacity: 1).pointee
            if name.hasPrefix("en") || name.hasPrefix("pdp_ip") || name.hasPrefix("awdl") {
                sent += networkData.ifi_obytes
                received += networkData.ifi_ibytes
            }
        }
        ptr = ptr!.pointee.ifa_next
    }
    freeifaddrs(addrs)
    return AppNetworkUsage(sent: sent, received: received)
}

// --------- Metrics système ---------
struct LocalSystemMetrics {
    static func ramUsedFraction() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kerr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        guard kerr == KERN_SUCCESS else { return 0 }
        let used = Double(info.resident_size)
        let deviceRam = Double(ProcessInfo.processInfo.physicalMemory)
        return used / deviceRam
    }
    private static let threadBasicInfoCount: mach_msg_type_number_t =
        UInt32(MemoryLayout<thread_basic_info_data_t>.size / MemoryLayout<integer_t>.size)

    static func cpuUsageFraction() -> Double {
        var threads: thread_act_array_t?
        var threadCount = mach_msg_type_number_t()
        let task = mach_task_self_
        guard task_threads(task, &threads, &threadCount) == KERN_SUCCESS, let threads = threads else { return 0 }
        var totalUsage: Double = 0
        for i in 0..<Int(threadCount) {
            var info = thread_basic_info()
            var count = threadBasicInfoCount
            let res = withUnsafeMutablePointer(to: &info) {
                $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                    thread_info(threads[i], thread_flavor_t(THREAD_BASIC_INFO), $0, &count)
                }
            }
            if res == KERN_SUCCESS && (info.flags & TH_FLAGS_IDLE) == 0 {
                totalUsage += Double(info.cpu_usage) / Double(TH_USAGE_SCALE)
            }
        }
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: threads), vm_size_t(threadCount) * vm_size_t(MemoryLayout<thread_t>.size))
        return totalUsage
    }
    static func storageInfo() -> (free: Double, total: Double)? {
        if let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory()),
            let free = attrs[.systemFreeSize] as? Double,
            let total = attrs[.systemSize] as? Double {
            return (free / 1024 / 1024 / 1024, total / 1024 / 1024 / 1024)
        }
        return nil
    }
}

// --------- Vue principale ---------
struct ContentView: View {
    @State private var ramFraction: Double = 0
    @State private var cpuFraction: Double = 0
    @State private var batteryLevel: Float = UIDevice.current.batteryLevel
    @State private var batteryState: UIDevice.BatteryState = UIDevice.current.batteryState

    @State private var lastUsage: AppNetworkUsage = getNetworkUsage()
    
    @StateObject var dlPublisher = DisplayLinkPublisher()
    
    @State private var frameCount: Int = 0
    
    @State private var totalDownload: Double = 0
    @State private var totalUpload: Double = 0
    
    @State private var netPoints: [NetworkSample] = [
        NetworkSample(upload: 10, download: 20),
        NetworkSample(upload: 12, download: 25),
        NetworkSample(upload: 8, download: 15),
        NetworkSample(upload: 11, download: 22)
    ]
    // Ensuite ton timer remplacera ces valeurs après quelques ticks.


    let timer = Timer.publish(every: 0.9, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // --------- Préparation des données ---------
                let stockageTuple = LocalSystemMetrics.storageInfo()
                let stockageTotal = stockageTuple?.total ?? 1.0
                let stockageUsed = stockageTuple != nil ? stockageTuple!.total - stockageTuple!.free : 0.0
                let percentUsed = stockageTotal > 0 ? stockageUsed / stockageTotal : 0

                let ramGo = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024
                let ramUsedGo = ramFraction * ramGo
                let percentRam = ramFraction

                let percentCpu = cpuFraction
                let percentBattery = Double(batteryLevel)

                // --------- Dashboard en grille 2x2 ---------
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    // (Prépare tes let avant, comme dans les exemples précédents)

                    StatAppleCard(
                        icon: "cpu",
                        iconColor: .white,
                        iconBg: Color.blue.opacity(0.85),
                        title: "CPU",
                        valueLeft: "Syst: 3.2%", // ou "", ce que tu veux sur la stat à gauche
                        valueRight: String(format: "%.1f%%", cpuFraction*100),
                        percent: cpuFraction,
                        barGradient: LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.cyan]),
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                    StatAppleCard(
                        icon: "memorychip",
                        iconColor: .white,
                        iconBg: Color.cyan.opacity(0.85),
                        title: "RAM",
                        valueLeft: String(format: "%.2f Go / %.2f Go", ramUsedGo, ramGo),
                        valueRight: String(format: "%.1f%%", percentRam*100),
                        percent: percentRam,
                        barGradient: LinearGradient(
                            gradient: Gradient(colors: [Color.cyan, Color.blue]),
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                    StatAppleCard(
                        icon: "internaldrive",
                        iconColor: .white,
                        iconBg: Color.purple.opacity(0.85),
                        title: "Stockage",
                        valueLeft: String(format: "%.1f G/%.1f G", stockageUsed, stockageTotal),
                        valueRight: String(format: "%.1f%%", percentUsed * 100),
                        percent: percentUsed,
                        barGradient: LinearGradient(
                            gradient: Gradient(colors: [Color.purple, Color.pink]),
                            startPoint: .leading, endPoint: .trailing
                        )
                    )

                    StatAppleCard(
                        icon: "battery.100",
                        iconColor: .white,
                        iconBg: Color.green.opacity(0.9),
                        title: "Batterie",
                        valueLeft: batteryState == .full ? "Full" : String(format: "%.0f", batteryLevel*100) + " %",
                        valueRight: "",
                        percent: percentBattery,
                        barGradient: LinearGradient(
                            gradient: Gradient(colors: [Color.green, Color(.systemTeal)]),
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                }
                // --------- Bloc graphique réseau ---------
                VStack(alignment: .leading, spacing: 7) {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.green)
                        Text("Réseau (KB/s)")
                            .font(.system(size: 13, weight: .semibold))
                            .font(.title2)
                            .bold()
                        Spacer()
                        if let pt = netPoints.last {
                            Text(String(format: "↓ %.1f / ↑ %.1f", pt.download, pt.upload))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    NetPanelCompact(
                        points: netPoints,
                        lastDownload: netPoints.last?.download ?? 0,
                        lastUpload: netPoints.last?.upload ?? 0
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
                .shadow(color: Color.blue.opacity(0.08), radius: 2, x: 0, y: 2)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshStats()
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                refreshStats()
                let usageNow = getNetworkUsage()
                let downKBs = Double(usageNow.received - lastUsage.received) / 1024.0
                let upKBs = Double(usageNow.sent - lastUsage.sent) / 1024.0
                netPoints.append(NetworkSample(upload: upKBs, download: downKBs))
                if netPoints.count > 40 { netPoints.removeFirst() }
                totalDownload += downKBs
                totalUpload += upKBs
                lastUsage = usageNow
            }
        }
    }
    func refreshStats() {
        ramFraction = min(max(LocalSystemMetrics.ramUsedFraction(), 0), 1)
        cpuFraction = min(max(LocalSystemMetrics.cpuUsageFraction(), 0), 1)
        batteryLevel = UIDevice.current.batteryLevel
        batteryState = UIDevice.current.batteryState
    }
}
