import SwiftUI

struct NetworkPanelCard: View {
    let netPoints: [NetworkSample]
    let totalDownload: Double
    let totalUpload: Double
    let isWiFi: Bool

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Réseau (KB/s)")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 8) {
                        // Download
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.right.circle")
                                .foregroundColor(.blue)
                                .font(.caption)
                            Text("\(String(format: "%.2f", (netPoints.last?.download ?? 0) / 1024)) MB/s")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                        // Upload
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up.right.circle")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("\(String(format: "%.2f", (netPoints.last?.upload ?? 0) / 1024)) MB/s")
                                .foregroundColor(.white)
                                .font(.caption)
                        }
                    }
                }

                Divider()
                    .background(Color(.secondarySystemFill))
                    .padding(.horizontal)

                // Graphique réseau
                NetworkGraphView(samples: netPoints)
            }
            .padding()
        }
        .background(RoundedRectangle(cornerRadius: 18).fill(Color.graphBackground))
        .padding()
    }
}
