import SwiftUI
import Combine
import Foundation
import Darwin
import Network

// MARK: - Enums & Data Models

enum NetworkType {
    case wifi
    case cellular
}

struct NetworkSample: Equatable {
    let upload: Double // KB/s
    let download: Double // KB/s
}

struct AppNetworkUsage {
    var sent: UInt64 = 0
    var received: UInt64 = 0
}

// MARK: - Main Content View

struct ContentView: View {
    @State private var ramFraction: Double = 0
    @State private var cpuFraction: Double = 0
    @State private var batteryLevel: Float = UIDevice.current.batteryLevel
    @State private var batteryState: UIDevice.BatteryState = UIDevice.current.batteryState
    @State private var lastUsage: AppNetworkUsage = getNetworkUsage()
    @State private var totalDownload: Double = 0
    @State private var totalUpload: Double = 0
    @State private var netPoints: [NetworkSample] = []
    @State private var isWiFi: Bool = true
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // MARK: - Cards Grid
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        // CPU Card
                        StatAppleCard(
                            icon: "cpu",
                            iconColor: .white,
                            iconBg: Color.blue.opacity(0.85),
                            title: "CPU",
                            valueLeft: "Syst: 3.2%",
                            valueRight: String(format: "%.1f%%", cpuFraction * 100),
                            percent: cpuFraction,
                            barGradient: LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.cyan]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            caseColor: .cardBackground
                        )
                        // RAM Card
                        let ramGo = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024
                        let ramUsedGo = ramFraction * ramGo
                        StatAppleCard(
                            icon: "memorychip",
                            iconColor: .white,
                            iconBg: Color.cyan.opacity(0.85),
                            title: "RAM",
                            valueLeft: String(format: "%.2f Go / %.2f Go", ramUsedGo, ramGo),
                            valueRight: String(format: "%.1f%%", ramFraction * 100),
                            percent: ramFraction,
                            barGradient: LinearGradient(
                                gradient: Gradient(colors: [Color.cyan, Color.blue]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            caseColor: .cardBackground
                        )
                        // Storage Card
                        let storageTuple = LocalSystemMetrics.storageInfo()
                        let storageTotal = storageTuple?.total ?? 1.0
                        let storageUsed = storageTuple != nil ? storageTuple!.total - storageTuple!.free : 0.0
                        let percentUsed = (storageTotal > 0) ? (storageUsed / storageTotal) : 0
                        StatAppleCard(
                            icon: "internaldrive",
                            iconColor: .white,
                            iconBg: Color.purple.opacity(0.85),
                            title: "Stockage",
                            valueLeft: String(format: "%.1f G/%.1f G", storageUsed, storageTotal),
                            valueRight: String(format: "%.1f%%", percentUsed * 100),
                            percent: percentUsed,
                            barGradient: LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.pink]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            caseColor: .cardBackground
                        )
                        // Battery Card
                        StatAppleCard(
                            icon: "battery.100",
                            iconColor: .white,
                            iconBg: appleBatteryColor(level: batteryLevel, state: batteryState),
                            title: "Batterie",
                            valueLeft: String(format: "%.0f%%", max(0, min(1, batteryLevel)) * 100),
                            valueRight: "",
                            percent: Double(max(0, min(batteryLevel, 1))),
                            barGradient: LinearGradient(
                                gradient: Gradient(colors: [
                                    appleBatteryColor(level: batteryLevel, state: batteryState),
                                    Color(.systemGray3)
                                ]),
                                startPoint: .leading, endPoint: .trailing
                            ),
                            valueStatus: batteryStatusText(batteryState),
                            caseColor: .cardBackground
                        )
                    }
                    // MARK: - Network Graph Case
                    CaseView(caseColor: .graphBackground) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Réseau (KB/s)")
                                    .font(.headline)
                                Spacer()
                                Text("↓ \(String(format: "%.2f", (netPoints.last?.download ?? 0) / 1024)) MB/s")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("↑ \(String(format: "%.2f", (netPoints.last?.upload ?? 0) / 1024)) MB/s")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                            NetPanelAppleRefined(
                                points: netPoints,
                                totalDownload: totalDownload,
                                totalUpload: totalUpload,
                                maxPoints: 28,
                                window: 7,
                                isWiFi: isWiFi
                            )
                            .frame(height: 130)
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Tableau de bord")
        }
        .preferredColorScheme(.dark)
        .onAppear {
            UIDevice.current.isBatteryMonitoringEnabled = true
            refreshStats()
            refreshNetworkType()
            NotificationCenter.default.addObserver(forName: UIDevice.batteryLevelDidChangeNotification, object: nil, queue: .main) { _ in
                refreshStats()
            }
            NotificationCenter.default.addObserver(forName: UIDevice.batteryStateDidChangeNotification, object: nil, queue: .main) { _ in
                refreshStats()
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.25)) {
                refreshStats()
                let usageNow = getNetworkUsage()
                let downKBs = usageNow.received >= lastUsage.received
                    ? Double(usageNow.received - lastUsage.received) / 1024.0
                    : 0.0
                let upKBs = usageNow.sent >= lastUsage.sent
                    ? Double(usageNow.sent - lastUsage.sent) / 1024.0
                    : 0.0
                netPoints.append(NetworkSample(upload: upKBs, download: downKBs))
                if netPoints.count > 40 { netPoints.removeFirst() }
                totalDownload += downKBs
                totalUpload += upKBs
                lastUsage = usageNow
            }
        }
    }

    // MARK: - Stat Refresh
    func refreshStats() {
        DispatchQueue.global().async {
            let ram = min(max(LocalSystemMetrics.ramUsedFraction(), 0), 1)
            let cpu = min(max(LocalSystemMetrics.cpuUsageFraction(), 0), 1)
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
}

// MARK: - StatAppleCard (Case)

struct StatAppleCard: View {
    let icon: String
    let iconColor: Color
    let iconBg: Color
    let title: String
    let valueLeft: String
    let valueRight: String
    let percent: Double
    let barGradient: LinearGradient
    var valueStatus: String? = nil
    var caseColor: Color = Color(.systemBackground)

    var body: some View {
        CaseView(caseColor: caseColor) {
            VStack(alignment: .leading, spacing: 10) {
                // En-tête icône + titre
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(iconBg)
                            .frame(width: 30, height: 30)
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(iconColor)
                    }
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                // Barre de progression TOUJOURS au-dessus
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.tertiarySystemFill))
                            .frame(height: 8)
                        Capsule()
                            .fill(barGradient)
                            .frame(width: geometry.size.width * CGFloat(max(min(percent, 1), 0)), height: 8)
                    }
                }
                .frame(height: 8)
                // Bloc statistiques ou status
                if let valueStatus = valueStatus {
                    HStack {
                        Text(valueStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(valueLeft)
                            .font(.subheadline)
                            .foregroundColor(iconBg)
                    }
                } else {
                    HStack(alignment: .firstTextBaseline) {
                        Text(valueLeft)
                            .font(.caption)
                            .foregroundColor(.primary)
                        Spacer()
                        Text(valueRight)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// MARK: - CaseView wrapper

struct CaseView<Content: View>: View {
    var title: String? = nil
    var caseColor: Color = Color(.systemBackground)
    var content: Content

    init(title: String? = nil, caseColor: Color = Color(.systemBackground), @ViewBuilder content: () -> Content) {
        self.title = title
        self.caseColor = caseColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(caseColor)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 2)
    }
}

// MARK: - Network Graph et Panel dans une case

struct NetPanelAppleRefined: View {
    let points: [NetworkSample]
    let totalDownload: Double // KB
    let totalUpload: Double   // KB
    let maxPoints: Int
    let window: Int
    let isWiFi: Bool

    var body: some View {
        VStack(spacing: 8) {
            // Utilisation totale
            HStack {
                Text("Utilisation totale")
                    .foregroundColor(.gray.opacity(0.88))
                    .font(.caption)
                Spacer()
                HStack(spacing: 10) {
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.down.circle")
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f Mo", totalDownload / 1024))
                            .foregroundColor(.primary)
                            .font(.caption)
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.green)
                        Text(String(format: "%.1f Mo", totalUpload / 1024))
                            .foregroundColor(.primary)
                            .font(.caption)
                    }
                }
            }
            NetGraphAppleRefined(points: points, maxPoints: maxPoints, window: window)
                .frame(height: 110)
        }
    }
}

// MARK: - DashedLine View

struct DashedLine: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: .zero)
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [7, 7]))
            .foregroundColor(Color.gray.opacity(0.25))
        }
    }
}

// MARK: - Network Graph et Smooth

struct NetGraphAppleRefined: View {
    let points: [NetworkSample]
    let maxPoints: Int
    let window: Int

    let downloadColor = Color.blue
    let uploadColor   = Color.green

    func rollingAverage(_ values: [Double]) -> [Double] {
        guard values.count > window else { return values }
        var avg: [Double] = []
        for i in 0..<values.count {
            let lower = max(0, i - window / 2)
            let upper = min(values.count - 1, i + window / 2)
            let slice = Array(values[lower...upper])
            avg.append(slice.reduce(0, +) / Double(slice.count))
        }
        return avg
    }

    func catmullRomPath(values: [Double], size: CGSize) -> Path? {
        let total = min(values.count, maxPoints)
        guard total > 3 else { return nil }
        let valmax = max(values.max() ?? 256, 256)
        let stepX = size.width / CGFloat(max(total - 1, 1))
        var pts: [CGPoint] = []
        for i in 0..<total {
            let x = CGFloat(i) * stepX
            let y = size.height - CGFloat(values[values.count - total + i] / valmax) * size.height
            pts.append(CGPoint(x: x, y: y))
        }
        var path = Path()
        path.move(to: pts[0])
        for i in 0..<pts.count-1 {
            let p0 = i > 0 ? pts[i-1] : pts[i]
            let p1 = pts[i]
            let p2 = pts[i+1]
            let p3 = (i+2 < pts.count) ? pts[i+2] : p2
            for t in stride(from: 0, through: 1, by: 0.13) {
                let tt = CGFloat(t)
                let x = 0.5 * ((2*p1.x)
                    + (-p0.x + p2.x)*tt
                    + (2*p0.x - 5*p1.x + 4*p2.x - p3.x)*tt*tt
                    + (-p0.x + 3*p1.x - 3*p2.x + p3.x)*tt*tt*tt)
                let y = 0.5 * ((2*p1.y)
                    + (-p0.y + p2.y)*tt
                    + (2*p0.y - 5*p1.y + 4*p2.y - p3.y)*tt*tt
                    + (-p0.y + 3*p1.y - 3*p2.y + p3.y)*tt*tt*tt)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }

    var body: some View {
        GeometryReader { geo in
            let gridVals = [256, 192, 128, 64]
            let verticalLines = 6
            let cases = 4
            ZStack {
                // Lignes horizontales
                ForEach(0...cases, id: \.self) { i in
                    let y = geo.size.height * CGFloat(Double(i) / Double(cases))
                    Path { path in
                        path.move(to: CGPoint(x: 50, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width-7, y: y))
                    }
                    .stroke(Color.gray.opacity(0.33), style: StrokeStyle(lineWidth: 0.8, dash: [5,5]))
                }
                // Labels
                ForEach(0..<gridVals.count, id: \.self) { i in
                    let y = geo.size.height * CGFloat((Double(i)+0.5)/Double(cases))
                    Text("\(gridVals[i]) KB/s")
                        .font(.caption2)
                        .foregroundColor(.blue.opacity(0.5))
                        .padding(3)
                        .background(RoundedRectangle(cornerRadius: 4).fill(Color.black.opacity(0.60)))
                        .position(x: 34, y: y)
                        .zIndex(2)
                }
                // Lignes verticales
                ForEach(0..<verticalLines, id: \.self) { i in
                    let x = CGFloat(i) * (geo.size.width-15) / CGFloat(verticalLines-1) + 7
                    Path { path in
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    .stroke(Color.gray.opacity(0.22), style: StrokeStyle(lineWidth: 1, dash: [5,5]))
                }
                // Courbes
                let smoothDownload = rollingAverage(points.map { $0.download })
                let smoothUpload = rollingAverage(points.map { $0.upload })
                if let dpath = catmullRomPath(values: smoothDownload, size: geo.size) {
                    dpath.stroke(downloadColor, style: StrokeStyle(lineWidth: 2.1, lineCap: .round))
                        .animation(.easeInOut(duration: 0.21), value: points)
                }
                if let upath = catmullRomPath(values: smoothUpload, size: geo.size) {
                    upath.stroke(uploadColor, style: StrokeStyle(lineWidth: 1.1, lineCap: .round))
                        .animation(.easeInOut(duration: 0.21), value: points)
                }
            }
        }
        .frame(height: 110)
    }
}

// MARK: - Utile: NetworkType, Usage, Storage

func getCurrentNetworkType(completion: @escaping (NetworkType) -> Void) {
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    monitor.pathUpdateHandler = { path in
        defer { monitor.cancel() }
        if path.usesInterfaceType(.wifi) {
            completion(.wifi)
        } else if path.usesInterfaceType(.cellular) {
            completion(.cellular)
        }
    }
    monitor.start(queue: queue)
}

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

// MARK: - Système Metrics

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

// MARK: - Batterie

func batteryStatusText(_ state: UIDevice.BatteryState) -> String {
    switch state {
        case .charging:  return "En charge"
        case .full:      return "Pleine"
        case .unplugged: return "Sur batterie"
        default:         return "-"
    }
}
func appleBatteryColor(level: Float, state: UIDevice.BatteryState, lowPower: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled) -> Color {
    if state == .unknown { return Color(.systemGray3) }
    if lowPower { return Color(.systemYellow) }
    if level <= 0.20 { return Color(.systemRed) }
    return Color(.systemGreen)
}

// MARK: - Couleurs custom pour cases

extension Color {
    static let cardBackground = Color(.secondarySystemBackground)
    static let graphBackground = Color(.secondarySystemGroupedBackground)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
