//
//  PreviewView.swift
//  AstroStackerPro
//
//  iOS 17+: usa onChange(of:initial:) ed evita mutazioni di stato durante il body.
//

import SwiftUI

struct PreviewView: View {
    var body: some View {
        StarsPlaceholderView()
    }
}

/// Semplice placeholder di anteprima con “campo stellare”
struct StarsPlaceholderView: View {
    @State private var stars: [CGPoint] = []
    @State private var twinkles: [Double] = []
    private let starCount: Int = 120

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                // sfondo
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(LinearGradient(colors: [.black.opacity(0.92), .black.opacity(0.65)],
                                         startPoint: .top, endPoint: .bottom))

                // stelle
                Canvas { context, _ in
                    guard stars.count == twinkles.count else { return }
                    for (i, p) in stars.enumerated() {
                        let r = 0.8 + 1.8 * abs(sin(twinkles[i]))
                        let rect = CGRect(x: p.x - r/2, y: p.y - r/2, width: r, height: r)
                        context.fill(Circle().path(in: rect), with: .color(.white.opacity(0.9)))
                    }
                }
            }
            // Generazione iniziale una sola volta
            .onAppear {
                let data = Self.generate(in: size, count: starCount)
                stars = data.points
                twinkles = data.twinkles
            }
            // iOS 17+: nuova API con old/new value
            .onChange(of: size, initial: false) { _, newSize in
                let data = Self.generate(in: newSize, count: starCount)
                stars = data.points
                twinkles = data.twinkles
            }
        }
        .frame(height: 240)
    }

    // MARK: - Generation (pure function → nessuna mutazione di stato qui)
    private static func generate(in size: CGSize, count: Int)
    -> (points: [CGPoint], twinkles: [Double]) {
        guard size.width > 0, size.height > 0, count > 0 else { return ([], []) }
        var pts: [CGPoint] = []
        var tw:  [Double]  = []
        pts.reserveCapacity(count)
        tw.reserveCapacity(count)

        for _ in 0..<count {
            pts.append(CGPoint(x: .random(in: 0...size.width),
                               y: .random(in: 0...size.height)))
            tw.append(Double.random(in: 0...(Double.pi * 2)))
        }
        return (pts, tw)
    }
}

// MARK: - Safe subscript helper (se serve altrove)
private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

