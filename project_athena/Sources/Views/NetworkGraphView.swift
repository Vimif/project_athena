//
//  NetworkGraphView.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 21/11/2025.
//

import SwiftUI

struct NetworkGraphView: View {
    let samples: [NetworkSample]
    
    private var maxDownload: Double {
        max(samples.map { $0.download }.max() ?? 100, 100)
    }
    
    private var maxUpload: Double {
        max(samples.map { $0.upload }.max() ?? 100, 100)
    }
    
    private var globalMax: Double {
        max(maxDownload, maxUpload)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Graphique principal
            graphContent
                .frame(height: 180)
            
            // Légende et informations
            legendView
                .padding(.top, 12)
        }
    }
    
    private var graphContent: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack(alignment: .bottom) {
                // Grille de fond
                gridBackground(width: width, height: height)
                
                // Zone de gradient pour download (remplie)
                downloadGradientArea(width: width, height: height)
                
                // Zone de gradient pour upload (remplie)
                uploadGradientArea(width: width, height: height)
                
                // Ligne download (smooth)
                downloadSmoothLine(width: width, height: height)
                
                // Ligne upload (smooth)
                uploadSmoothLine(width: width, height: height)
                
                // Points de données
                dataPoints(width: width, height: height)
            }
        }
    }
    
    // MARK: - Grille de fond
    
    private func gridBackground(width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            // Lignes horizontales
            ForEach(0..<5) { i in
                Path { path in
                    let y = height * CGFloat(i) / 4
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            }
        }
    }
    
    // MARK: - Calcul des points normalisés
    
    private func normalizedPoints(for values: [Double], width: CGFloat, height: CGFloat) -> [CGPoint] {
        guard !samples.isEmpty else { return [] }
        
        let stepX = width / CGFloat(max(samples.count - 1, 1))
        
        return values.enumerated().map { index, value in
            let x = CGFloat(index) * stepX
            let normalizedValue = value / globalMax
            let y = height * (1 - CGFloat(normalizedValue))
            return CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Courbe de Bézier lisse
    
    private func createSmoothPath(points: [CGPoint]) -> Path {
        var path = Path()
        
        guard points.count > 1 else {
            if let point = points.first {
                path.move(to: point)
            }
            return path
        }
        
        path.move(to: points[0])
        
        // Si seulement 2 points, ligne droite
        if points.count == 2 {
            path.addLine(to: points[1])
            return path
        }
        
        // Pour 3+ points, utiliser des courbes de Bézier cubiques
        for i in 0..<points.count {
            if i == 0 {
                // Premier point : demi-courbe vers le suivant
                let nextPoint = points[1]
                let controlPoint = CGPoint(
                    x: (points[0].x + nextPoint.x) / 2,
                    y: points[0].y
                )
                path.addQuadCurve(to: controlPoint, control: points[0])
            } else if i == points.count - 1 {
                // Dernier point : demi-courbe depuis le précédent
                let controlPoint = CGPoint(
                    x: (points[i-1].x + points[i].x) / 2,
                    y: points[i].y
                )
                path.addQuadCurve(to: points[i], control: controlPoint)
            } else {
                // Points intermédiaires : courbe de Bézier cubique
                let previousPoint = points[i-1]
                let currentPoint = points[i]
                let nextPoint = points[i+1]
                
                // Points de contrôle pour une courbe douce
                let controlPoint1 = CGPoint(
                    x: previousPoint.x + (currentPoint.x - previousPoint.x) * 0.5,
                    y: previousPoint.y + (currentPoint.y - previousPoint.y) * 0.1
                )
                
                let controlPoint2 = CGPoint(
                    x: currentPoint.x - (nextPoint.x - currentPoint.x) * 0.5,
                    y: currentPoint.y - (nextPoint.y - currentPoint.y) * 0.1
                )
                
                path.addCurve(to: currentPoint, control1: controlPoint1, control2: controlPoint2)
            }
        }
        
        return path
    }
    
    // MARK: - Zone gradient Download (avec courbe smooth)
    
    private func downloadGradientArea(width: CGFloat, height: CGFloat) -> some View {
        let downloadValues = samples.map { $0.download }
        let points = normalizedPoints(for: downloadValues, width: width, height: height)
        
        var path = createSmoothPath(points: points)
        
        // Fermer le chemin pour créer une zone remplie
        if let lastPoint = points.last {
            path.addLine(to: CGPoint(x: lastPoint.x, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
        
        return path
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    // MARK: - Zone gradient Upload (avec courbe smooth)
    
    private func uploadGradientArea(width: CGFloat, height: CGFloat) -> some View {
        let uploadValues = samples.map { $0.upload }
        let points = normalizedPoints(for: uploadValues, width: width, height: height)
        
        var path = createSmoothPath(points: points)
        
        if let lastPoint = points.last {
            path.addLine(to: CGPoint(x: lastPoint.x, y: height))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.closeSubpath()
        }
        
        return path
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(0.25),
                        Color.green.opacity(0.03)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }
    
    // MARK: - Ligne Download smooth
    
    private func downloadSmoothLine(width: CGFloat, height: CGFloat) -> some View {
        let downloadValues = samples.map { $0.download }
        let points = normalizedPoints(for: downloadValues, width: width, height: height)
        let path = createSmoothPath(points: points)
        
        return path
            .stroke(
                Color.blue,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
    }
    
    // MARK: - Ligne Upload smooth
    
    private func uploadSmoothLine(width: CGFloat, height: CGFloat) -> some View {
        let uploadValues = samples.map { $0.upload }
        let points = normalizedPoints(for: uploadValues, width: width, height: height)
        let path = createSmoothPath(points: points)
        
        return path
            .stroke(
                Color.green,
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )
    }
    
    // MARK: - Points de données
    
    private func dataPoints(width: CGFloat, height: CGFloat) -> some View {
        Group {
            // Point download (dernier point seulement)
            if !samples.isEmpty {
                let downloadValues = samples.map { $0.download }
                let points = normalizedPoints(for: downloadValues, width: width, height: height)
                
                if let lastPoint = points.last {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                        .position(lastPoint)
                        .shadow(color: Color.blue.opacity(0.5), radius: 4, x: 0, y: 0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .position(lastPoint)
                }
            }
            
            // Point upload (dernier point seulement)
            if !samples.isEmpty {
                let uploadValues = samples.map { $0.upload }
                let points = normalizedPoints(for: uploadValues, width: width, height: height)
                
                if let lastPoint = points.last {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(lastPoint)
                        .shadow(color: Color.green.opacity(0.5), radius: 4, x: 0, y: 0)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                        .position(lastPoint)
                }
            }
        }
    }
    
    // MARK: - Légende
    
    private var legendView: some View {
        HStack(spacing: 20) {
            // Download
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                Text("Téléchargement")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Upload
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("Envoi")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Pic max
            Text("Max: \(formatSpeed(globalMax))")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper
    
    private func formatSpeed(_ kbps: Double) -> String {
        if kbps >= 1024 {
            return String(format: "%.1f MB/s", kbps / 1024)
        } else {
            return String(format: "%.0f KB/s", kbps)
        }
    }
}
