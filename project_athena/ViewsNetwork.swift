////
////  ViewNetwork.swift
////  project_athena
////
////  Created by Thomas Boisaubert on 18/11/2025.
////
//
//import Foundation
//import SwiftUI
//
//struct NetworkUsage {
//    var sent: UInt32 = 0
//    var received: UInt32 = 0
//}
//
//func getNetworkUsage() -> NetworkUsage {
//    var sent: UInt32 = 0
//    var received: UInt32 = 0
//    var addrs: UnsafeMutablePointer<ifaddrs>? = nil
//    guard getifaddrs(&addrs) == 0, let firstAddr = addrs else { return NetworkUsage(sent: 0, received: 0) }
//    var ptr = firstAddr
//    while ptr.pointee.ifa_next != nil {
//        let name = String(cString: ptr.pointee.ifa_name)
//        if let data = ptr.pointee.ifa_data {
//            let networkData = data.bindMemory(to: if_data.self, capacity: 1).pointee
//            // Nous filtrons les interfaces wifi/ethernet principalement (en général "en0", "en1", "pdp_ip0" pour cellulaire)
//            if name.hasPrefix("en") || name.hasPrefix("pdp_ip") || name.hasPrefix("awdl") {
//                sent += networkData.ifi_obytes
//                received += networkData.ifi_ibytes
//            }
//        }
//        ptr = ptr.pointee.ifa_next!
//    }
//    freeifaddrs(addrs)
//    return NetworkUsage(sent: sent, received: received)
//}
//
//struct NetPoint: Equatable {
//    let upload: Double // KB/s
//    let download: Double // KB/s
//}
//
///// Un graphique ligne simple pour visualiser l’évolution upload/download réseau en temps réel
//struct NetworkGraph: View {
//    let points: [NetPoint]
//    var maxPoints: Int = 40 // nombre d’historique (secondes)
//    var body: some View {
//        GeometryReader { geo in
//            ZStack {
//                // Fond dégradé léger
//                LinearGradient(
//                    gradient: Gradient(colors: [Color.green.opacity(0.10), Color.blue.opacity(0.10)]),
//                    startPoint: .top,
//                    endPoint: .bottom)
//                    .cornerRadius(10)
//                // Axes horizontaux gradués
//                ForEach(0..<5) { i in
//                    let y = geo.size.height * CGFloat(i) / 4
//                    Path { path in
//                        path.move(to: CGPoint(x: 0, y: y))
//                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
//                    }
//                    .stroke(Color.secondary.opacity(0.13), style: StrokeStyle(lineWidth: 1, dash: [3]))
//                }
//                // Courbe download (verte)
//                downloadPath(in: geo.size)
//                    .stroke(Color.green, style: StrokeStyle(lineWidth: 3, lineCap: .round))
//                    .animation(.easeInOut, value: points)
//                // Courbe upload (bleue)
//                uploadPath(in: geo.size)
//                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
//                    .animation(.easeInOut, value: points)
//            }
//        }
//        .frame(height: 120)
//        .padding(.vertical, 6)
//    }
//
//    // Tracé download
//    func downloadPath(in size: CGSize) -> Path {
//        var path = Path()
//        guard !points.isEmpty else { return path }
//        let total = min(points.count, maxPoints)
//        let maxDown = max(points.map{$0.download}.max() ?? 1, 1)
//        let stepX = size.width / CGFloat(max(total-1, 1))
//        for i in 0..<total {
//            let x = CGFloat(i) * stepX
//            let y = size.height - CGFloat(points[points.count-total+i].download / maxDown) * size.height
//            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
//            else { path.addLine(to: CGPoint(x: x, y: y)) }
//        }
//        return path
//    }
//
//    // Tracé upload
//    func uploadPath(in size: CGSize) -> Path {
//        var path = Path()
//        guard !points.isEmpty else { return path }
//        let total = min(points.count, maxPoints)
//        let maxUp = max(points.map{$0.upload}.max() ?? 1, 1)
//        let stepX = size.width / CGFloat(max(total-1, 1))
//        for i in 0..<total {
//            let x = CGFloat(i) * stepX
//            let y = size.height - CGFloat(points[points.count-total+i].upload / maxUp) * size.height
//            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
//            else { path.addLine(to: CGPoint(x: x, y: y)) }
//        }
//        return path
//    }
//}
