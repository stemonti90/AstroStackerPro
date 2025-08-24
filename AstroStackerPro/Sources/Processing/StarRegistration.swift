import Foundation
import CoreImage
import CoreGraphics

/// Allineamento frame basato su riconoscimento stelle (stub compatibile).
/// Questa versione definisce anche il tipo annidato `StarFeature` perché
/// alcuni file (es. SkyRecognizer) lo referenziano come `StarRegistration.StarFeature`.
final class StarRegistration {

    /// Feature stellare rilevata nell'immagine
    struct StarFeature {
        let position: CGPoint
        let brightness: Double
        init(position: CGPoint, brightness: Double) {
            self.position = position
            self.brightness = brightness
        }
    }

    init() {}

    /// Rilevamento stelle (placeholder). Restituisce un array vuoto per compatibilità.
    func detectStars(in image: CIImage) -> [StarFeature] {
        return []
    }

    /// Allineamento dei frame (placeholder: passthrough).
    /// Mantiene la firma minimale usata dal resto del progetto.
    func align(_ images: [CIImage]) -> [CIImage] {
        return images
    }
}

