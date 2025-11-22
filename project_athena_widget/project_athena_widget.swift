//
//  project_athena_widget.swift
//  project_athena_widget
//
//  Created by Thomas Boisaubert on 22/11/2025.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), data: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> ()) {
        let data = WidgetDataService.shared.loadWidgetData() ?? .placeholder
        let entry = WidgetEntry(date: Date(), data: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let data = WidgetDataService.shared.loadWidgetData() ?? .placeholder
        let entry = WidgetEntry(date: currentDate, data: data)
        
        // Rafraîchir toutes les 2 minutes (recommandation Apple)
        let nextUpdate = Calendar.current.date(byAdding: .second, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

// MARK: - Entry

struct WidgetEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Widget View

struct project_athena_widgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(data: entry.data)
        case .systemMedium:
            MediumWidgetView(data: entry.data)
        case .systemLarge:
            LargeWidgetView(data: entry.data)
        @unknown default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Small Widget (Norme Apple)

struct SmallWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // En-tête compact
            HStack(spacing: 6) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue)
                
                Text("Athena")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.bottom, 12)
            
            // Métriques principales avec barres
            VStack(spacing: 8) {
                CompactMetric(
                    icon: "cpu",
                    color: .blue,
                    label: "CPU",
                    value: data.cpuUsage,
                    displayValue: "\(Int(data.cpuUsage * 100))%"
                )
                
                CompactMetric(
                    icon: "memorychip",
                    color: .purple,
                    label: "RAM",
                    value: data.ramUsage,
                    displayValue: "\(Int(data.ramUsage * 100))%"
                )
                
                CompactMetric(
                    icon: "internaldrive",
                    color: .orange,
                    label: "Stockage",
                    value: data.storageUsage,
                    displayValue: "\(Int(data.storageUsage * 100))%"
                )
                
                CompactMetric(
                    icon: batteryIcon(data.batteryLevel),
                    color: batteryColor(data.batteryLevel, state: data.batteryState),
                    label: "Batterie",
                    value: Double(data.batteryLevel),
                    displayValue: "\(Int(data.batteryLevel * 100))%"
                )
            }
            
            Spacer()
        }
        .padding(16)
        .widgetBackground()
    }
    
    private func batteryIcon(_ level: Float) -> String {
        if level >= 0.75 { return "battery.100percent" }
        else if level >= 0.5 { return "battery.75percent" }
        else if level >= 0.25 { return "battery.50percent" }
        else { return "battery.25percent" }
    }
    
    private func batteryColor(_ level: Float, state: String) -> Color {
        if state == "charging" { return .green }
        else if level >= 0.5 { return .green }
        else if level >= 0.2 { return .orange }
        else { return .red }
    }
}


// MARK: - Medium Widget (Norme Apple)

struct MediumWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        HStack(spacing: 0) {
            // Section système
            VStack(alignment: .leading, spacing: 0) {
                // En-tête
                HStack(spacing: 6) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                    
                    Text("Système")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.bottom, 12)
                
                // Métriques
                VStack(spacing: 8) {
                    CompactMetric(
                        icon: "cpu",
                        color: .blue,
                        label: "CPU",
                        value: data.cpuUsage,
                        displayValue: "\(Int(data.cpuUsage * 100))%"
                    )
                    
                    CompactMetric(
                        icon: "memorychip",
                        color: .purple,
                        label: "RAM",
                        value: data.ramUsage,
                        displayValue: "\(Int(data.ramUsage * 100))%"
                    )
                    
                    CompactMetric(
                        icon: "internaldrive",
                        color: .orange,
                        label: "Stockage",
                        value: data.storageUsage,
                        displayValue: "\(Int(data.storageUsage * 100))%"
                    )
                    
                    CompactMetric(
                        icon: batteryIcon(data.batteryLevel),
                        color: batteryColor(data.batteryLevel, state: data.batteryState),
                        label: "Batterie",
                        value: Double(data.batteryLevel),
                        displayValue: "\(Int(data.batteryLevel * 100))%"
                    )
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            
            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(width: 1)
                .padding(.vertical, 12)
            
            // Section réseau
            VStack(alignment: .leading, spacing: 0) {
                // En-tête
                HStack(spacing: 6) {
                    Image(systemName: data.isWiFi ? "wifi" : "antenna.radiowaves.left.and.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(data.isWiFi ? .blue : .orange)
                    
                    Text("Réseau")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                }
                .padding(.bottom, 12)
                
                // Vitesses
                VStack(spacing: 16) {
                    NetworkSpeed(
                        icon: "arrow.down.circle.fill",
                        color: .blue,
                        label: "Download",
                        speed: formatSpeed(data.networkDownload)
                    )
                    
                    NetworkSpeed(
                        icon: "arrow.up.circle.fill",
                        color: .green,
                        label: "Upload",
                        speed: formatSpeed(data.networkUpload)
                    )
                    
                    // Type de connexion
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                        
                        Text(data.isWiFi ? "Wi-Fi" : "Cellulaire")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
        }
        .widgetBackground()
    }
    
    private func batteryIcon(_ level: Float) -> String {
        if level >= 0.75 { return "battery.100percent" }
        else if level >= 0.5 { return "battery.75percent" }
        else if level >= 0.25 { return "battery.50percent" }
        else { return "battery.25percent" }
    }
    
    private func batteryColor(_ level: Float, state: String) -> Color {
        if state == "charging" { return .green }
        else if level >= 0.5 { return .green }
        else if level >= 0.2 { return .orange }
        else { return .red }
    }
    
    private func formatSpeed(_ kbps: Double) -> String {
        if kbps >= 1024 {
            return String(format: "%.1f MB/s", kbps / 1024)
        }
        return String(format: "%.0f KB/s", kbps)
    }
}

// MARK: - Large Widget (Norme Apple)

struct LargeWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // En-tête global
            HStack(spacing: 8) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Project Athena")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Surveillance système")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(data.timestamp, style: .time)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("Mise à jour")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.bottom, 16)
            
            // Grille de métriques
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ],
                spacing: 12
            ) {
                MetricCard(
                    icon: "cpu",
                    color: .blue,
                    label: "CPU",
                    value: "\(Int(data.cpuUsage * 100))%",
                    percent: data.cpuUsage
                )
                
                MetricCard(
                    icon: "memorychip",
                    color: .purple,
                    label: "RAM",
                    value: "\(Int(data.ramUsage * 100))%",
                    percent: data.ramUsage
                )
                
                MetricCard(
                    icon: "internaldrive",
                    color: .orange,
                    label: "Stockage",
                    value: "\(Int(data.storageUsage * 100))%",
                    percent: data.storageUsage
                )
                
                MetricCard(
                    icon: batteryIcon(data.batteryLevel),
                    color: batteryColor(data.batteryLevel, state: data.batteryState),
                    label: "Batterie",
                    value: "\(Int(data.batteryLevel * 100))%",
                    percent: Double(data.batteryLevel)
                )
            }
            .padding(.bottom, 16)
            
            // Divider
            Rectangle()
                .fill(Color(.separator).opacity(0.3))
                .frame(height: 1)
                .padding(.bottom, 12)
            
            // Section réseau
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: data.isWiFi ? "wifi" : "antenna.radiowaves.left.and.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(data.isWiFi ? .blue : .orange)
                        
                        Text(data.isWiFi ? "Wi-Fi" : "Cellulaire")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    HStack(spacing: 16) {
                        NetworkSpeedLarge(
                            icon: "arrow.down.circle.fill",
                            color: .blue,
                            label: "Download",
                            speed: formatSpeed(data.networkDownload)
                        )
                        
                        NetworkSpeedLarge(
                            icon: "arrow.up.circle.fill",
                            color: .green,
                            label: "Upload",
                            speed: formatSpeed(data.networkUpload)
                        )
                    }
                }
                
                Spacer()
            }
        }
        .padding(16)
        .widgetBackground()
    }
    
    private func batteryIcon(_ level: Float) -> String {
        if level >= 0.75 { return "battery.100percent" }
        else if level >= 0.5 { return "battery.75percent" }
        else if level >= 0.25 { return "battery.50percent" }
        else { return "battery.25percent" }
    }
    
    private func batteryColor(_ level: Float, state: String) -> Color {
        if state == "charging" { return .green }
        else if level >= 0.5 { return .green }
        else if level >= 0.2 { return .orange }
        else { return .red }
    }
    
    private func formatSpeed(_ kbps: Double) -> String {
        if kbps >= 1024 {
            return String(format: "%.1f MB/s", kbps / 1024)
        }
        return String(format: "%.0f KB/s", kbps)
    }
}

// MARK: - Composants réutilisables (Norme Apple)

struct CompactMetric: View {
    let icon: String
    let color: Color
    let label: String
    let value: Double
    let displayValue: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(color)
                    .frame(width: 14)
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(displayValue)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
            }
            
            // Barre de progression
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 3)
                    
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(min(max(value, 0), 1)), height: 3)
                }
            }
            .frame(height: 3)
        }
    }
}

struct MetricCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let percent: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(color.opacity(0.15))
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(color)
                }
                
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .monospacedDigit()
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(color.gradient)
                        .frame(width: geo.size.width * CGFloat(min(max(percent, 0), 1)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.secondarySystemFill).opacity(0.5))
        )
    }
}

struct NetworkSpeed: View {
    let icon: String
    let color: Color
    let label: String
    let speed: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(speed)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .monospacedDigit()
                
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}

struct NetworkSpeedLarge: View {
    let icon: String
    let color: Color
    let label: String
    let speed: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundStyle(color)
                
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Text(speed)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .monospacedDigit()
        }
    }
}

// MARK: - Widget Background Extension (iOS 17+)

extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            self.containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        } else {
            self.background(Color(.systemBackground))
        }
    }
}

// MARK: - Widget Configuration

struct project_athena_widget: Widget {
    let kind: String = "project_athena_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            project_athena_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("Athena Dashboard")
        .description("Surveillez les performances de votre iPhone en temps réel.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled() // iOS 17+ pour supprimer les marges par défaut
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    project_athena_widget()
} timeline: {
    WidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemMedium) {
    project_athena_widget()
} timeline: {
    WidgetEntry(date: .now, data: .placeholder)
}

#Preview(as: .systemLarge) {
    project_athena_widget()
} timeline: {
    WidgetEntry(date: .now, data: .placeholder)
}
