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
        
        // Rafraîchir toutes les 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
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
        default:
            SmallWidgetView(data: entry.data)
        }
    }
}

// MARK: - Shared Helpers

private func sharedBatteryIcon(_ level: Float) -> String {
    if level >= 0.75 { return "battery.100percent" }
    else if level >= 0.5 { return "battery.75percent" }
    else if level >= 0.25 { return "battery.50percent" }
    else { return "battery.25percent" }
}

private func sharedBatteryColor(_ level: Float) -> Color {
    if level >= 0.5 { return .green }
    else if level >= 0.2 { return .yellow }
    else { return .red }
}

private func sharedFormatSpeed(_ kbps: Double) -> String {
    if kbps >= 1024 {
        return String(format: "%.1f MB/s", kbps / 1024)
    }
    return String(format: "%.0f KB/s", kbps)
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(spacing: 8) {
            // En-tête
            HStack {
                Image(systemName: "iphone.gen3")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("Athena")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            Divider()
            
            // Métriques
            VStack(spacing: 6) {
                MetricRow(icon: "cpu", color: .blue, label: "CPU", value: "\(Int(data.cpuUsage * 100))%")
                MetricRow(icon: "memorychip", color: .purple, label: "RAM", value: "\(Int(data.ramUsage * 100))%")
                MetricRow(icon: "internaldrive", color: .orange, label: "Stockage", value: "\(Int(data.storageUsage * 100))%")
                MetricRow(icon: sharedBatteryIcon(data.batteryLevel), color: sharedBatteryColor(data.batteryLevel), label: "Batterie", value: "\(Int(data.batteryLevel * 100))%")
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        HStack(spacing: 12) {
            // Colonne gauche : Métriques système
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "iphone.gen3")
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text("Athena")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Divider()
                
                VStack(spacing: 6) {
                    MetricRow(icon: "cpu", color: .blue, label: "CPU", value: "\(Int(data.cpuUsage * 100))%")
                    MetricRow(icon: "memorychip", color: .purple, label: "RAM", value: "\(Int(data.ramUsage * 100))%")
                    MetricRow(icon: "internaldrive", color: .orange, label: "Stockage", value: "\(Int(data.storageUsage * 100))%")
                    MetricRow(icon: sharedBatteryIcon(data.batteryLevel), color: sharedBatteryColor(data.batteryLevel), label: "Batterie", value: "\(Int(data.batteryLevel * 100))%")
                }
            }
            
            Divider()
            
            // Colonne droite : Réseau
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: data.isWiFi ? "wifi" : "antenna.radiowaves.left.and.right")
                        .font(.caption)
                        .foregroundColor(data.isWiFi ? .blue : .orange)
                    Text("Réseau")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                }
                
                Divider()
                
                VStack(spacing: 12) {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("Download")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(sharedFormatSpeed(data.networkDownload))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.green)
                            Text("Upload")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        Text(sharedFormatSpeed(data.networkUpload))
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Large Widget

struct LargeWidgetView: View {
    let data: WidgetData
    
    var body: some View {
        VStack(spacing: 12) {
            // En-tête
            HStack {
                Image(systemName: "iphone.gen3")
                    .foregroundColor(.blue)
                Text("Project Athena")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text(data.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Grille de métriques
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                LargeMetricCard(icon: "cpu", color: .blue, label: "CPU", value: "\(Int(data.cpuUsage * 100))%", percent: data.cpuUsage)
                LargeMetricCard(icon: "memorychip", color: .purple, label: "RAM", value: "\(Int(data.ramUsage * 100))%", percent: data.ramUsage)
                LargeMetricCard(icon: "internaldrive", color: .orange, label: "Stockage", value: "\(Int(data.storageUsage * 100))%", percent: data.storageUsage)
                LargeMetricCard(icon: sharedBatteryIcon(data.batteryLevel), color: sharedBatteryColor(data.batteryLevel), label: "Batterie", value: "\(Int(data.batteryLevel * 100))%", percent: Double(data.batteryLevel))
            }
            
            Divider()
            
            // Réseau
            HStack(spacing: 16) {
                VStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                    Text(sharedFormatSpeed(data.networkDownload))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Download")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    Text(sharedFormatSpeed(data.networkUpload))
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                    Text("Upload")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// MARK: - Helper Views

struct MetricRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
}

struct LargeMetricCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let percent: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(min(max(percent, 0), 1)), height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(8)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Widget Configuration

struct project_athena_widget: Widget {
    let kind: String = "project_athena_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            project_athena_widgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Athena Dashboard")
        .description("Surveillez les performances de votre iPhone en temps réel.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

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
