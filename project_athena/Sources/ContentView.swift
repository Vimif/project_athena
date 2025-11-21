import SwiftUI
import Combine
import Network

// MARK: - Enums & Data Models

enum NetworkType {
    case wifi
    case cellular
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
                    DeviceInfoCard()
                    // MARK: - Cards Grid
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: 16
                    ) {
                        // CPU Card
                    
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
                            .font(Font.caption.bold())
                        Text(String(format: "%.1f Mo", totalDownload / 1024))
                            .foregroundColor(.primary)
                            .font(.caption)
                    }
                    HStack(spacing: 2) {
                        Image(systemName: "arrow.up.circle")
                            .foregroundColor(.green)
                            .font(.caption.bold())
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

// MARK: - Batterie
func appleBatteryColor(level: Float, state: UIDevice.BatteryState, lowPower: Bool = ProcessInfo.processInfo.isLowPowerModeEnabled) -> Color {
    if state == .unknown { return Color(.systemGray3) }
    if lowPower { return Color(.systemYellow) }
    if level <= 0.20 { return Color(.systemRed) }
    return Color(.systemGreen)
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
