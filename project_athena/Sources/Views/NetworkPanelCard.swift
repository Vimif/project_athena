//
//  NetworkPanelCard.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 20/11/2025.
//

import SwiftUI

struct NetworkCard: View {
    let netPoints: [NetworkSample]
    let totalDownload: Double
    let totalUpload: Double
    let isWiFi: Bool

    var body: some View {
        CaseView(caseColor: .graphBackground) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Réseau (KB/s)")
                        .font(.headline)
                        .foregroundColor(.white) // ou .primary
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
