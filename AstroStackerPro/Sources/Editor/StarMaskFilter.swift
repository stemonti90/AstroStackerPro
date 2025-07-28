import CoreImage

final class StarMaskFilter {
    static func maskStars(_ img: CIImage) -> CIImage {
        // Placeholder: high-pass + threshold
        let hp = img.applyingFilter("CIHighPass", parameters: ["inputRadius": 2.0])
        let bw = hp.applyingFilter("CIColorControls", parameters: ["inputSaturation": 0, "inputContrast": 2])
        return bw.applyingFilter("CIColorMatrix", parameters: [
            "inputRVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputGVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputBVector": CIVector(x: 0, y: 0, z: 0, w: 1),
            "inputAVector": CIVector(x: 1, y: 1, z: 1, w: 0)
        ])
    }
}
