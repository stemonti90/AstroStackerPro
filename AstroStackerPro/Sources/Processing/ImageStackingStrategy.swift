import Foundation
import CoreImage

/// Strategie disponibili per lo stacking.
/// Deve esistere una sola definizione in tutto il target.
public enum ImageStackingStrategy {
    case average
    case median
    case maximum
    case hdr
}

/// Esecutore dello stacking. Implementazioni sicure e semplici
/// per evitare conflitti e ambiguità nelle chiamate.
final class StackEngine {

    init() {}

    /// Esegue lo stacking secondo la strategia richiesta.
    /// `median` e `hdr` ricadono su `average` per semplicità (compatibilità).
    func stack(_ images: [CIImage], strategy: ImageStackingStrategy) -> CIImage? {
        guard !images.isEmpty else { return nil }
        switch strategy {
        case .average:
            return average(images)
        case .median:
            return average(images)
        case .maximum:
            return maximum(images)
        case .hdr:
            return average(images)
        }
    }

    // MARK: - Helpers

    /// Media: somma e normalizzazione N.
    private func average(_ images: [CIImage]) -> CIImage? {
        guard var acc = images.first else { return nil }
        for img in images.dropFirst() {
            if let f = CIFilter(name: "CIAdditionCompositing") {
                f.setValue(acc, forKey: kCIInputBackgroundImageKey)
                f.setValue(img, forKey: kCIInputImageKey)
                acc = f.outputImage ?? acc
            }
        }
        let n = CGFloat(images.count)
        if let f = CIFilter(name: "CIColorMatrix") {
            f.setValue(acc, forKey: kCIInputImageKey)
            let s = 1.0 / n
            f.setValue(CIVector(x: s, y: 0, z: 0, w: 0), forKey: "inputRVector")
            f.setValue(CIVector(x: 0, y: s, z: 0, w: 0), forKey: "inputGVector")
            f.setValue(CIVector(x: 0, y: 0, z: s, w: 0), forKey: "inputBVector")
            return f.outputImage ?? acc
        }
        return acc
    }

    /// Massimo: compositing progressivo col massimo per canale.
    private func maximum(_ images: [CIImage]) -> CIImage? {
        guard var acc = images.first else { return nil }
        for img in images.dropFirst() {
            if let f = CIFilter(name: "CIMaximumCompositing") {
                f.setValue(img, forKey: kCIInputImageKey)
                f.setValue(acc, forKey: kCIInputBackgroundImageKey)
                acc = f.outputImage ?? acc
            }
        }
        return acc
    }
}

