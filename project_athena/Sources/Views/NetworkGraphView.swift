//
//  NetworkGraphView.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 21/11/2025.
//

import SwiftUI

struct NetworkGraphView: View {
    let samples: [NetworkSample]

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let count = samples.count
            let maxDL = max(samples.map { $0.download }.max() ?? 1, 1)
            let maxUL = max(samples.map { $0.upload }.max() ?? 1, 1)
            let stepX = count > 1 ? w / CGFloat(count - 1) : 0

            // Download curve (bleu)
            Path { path in
                for i in samples.indices {
                    let val = samples[i].download
                    let y = h - CGFloat(val) / CGFloat(maxDL) * (h * 0.8)
                    let x = CGFloat(i) * stepX
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .opacity(0.85)

            // Upload curve (vert)
            Path { path in
                for i in samples.indices {
                    let val = samples[i].upload
                    let y = h - CGFloat(val) / CGFloat(maxUL) * (h * 0.8)
                    let x = CGFloat(i) * stepX
                    if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                    else { path.addLine(to: CGPoint(x: x, y: y)) }
                }
            }
            .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .opacity(0.7)

            // Optionnel : fond
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6)).opacity(0.5)
        }
        .frame(height: 130)
        .padding(.vertical, 4)
    }
}
