//
//  DisplayLinkPublisher.swift
//  project_athena
//
//  Created by Thomas Boisaubert on 19/11/2025.
//

import SwiftUI
import Combine
import QuartzCore

/// Publisher qui émet à chaque frame d'écran (~60Hz)
final class DisplayLinkPublisher: ObservableObject {
    @Published var tick: CGFloat = 0
    var link: CADisplayLink?

    init() {
        link = CADisplayLink(target: self, selector: #selector(draw))
        link?.add(to: .main, forMode: .common)
    }

    deinit { link?.invalidate() }

    @objc func draw() {
        tick = CGFloat(CACurrentMediaTime())
    }
}
