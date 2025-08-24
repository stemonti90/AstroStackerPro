//
//  AIDenoiser.swift
//  AstroStackerPro
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// Unico denoiser dell’app (rimuovi eventuali duplicati in altri path)
final class AIDenoiser {
    static let shared = AIDenoiser()
    private let context = CIContext()

    /// Denoise su CIImage (parametri in [0,1])
    func denoise(image: CIImage, noiseLevel: Float = 0.35, sharpness: Float = 0.4) -> CIImage {
        let f = CIFilter.noiseReduction()
        f.inputImage = image
        f.noiseLevel = noiseLevel
        f.sharpness = sharpness
        return f.outputImage ?? image
    }

    /// Denoise su UIImage
    func denoise(uiImage: UIImage, noiseLevel: Float = 0.35, sharpness: Float = 0.4) -> UIImage {
        guard let cg = uiImage.cgImage else { return uiImage }
        let ci = CIImage(cgImage: cg)
        let out = denoise(image: ci, noiseLevel: noiseLevel, sharpness: sharpness)
        guard let outCG = context.createCGImage(out, from: out.extent) else { return uiImage }
        return UIImage(cgImage: outCG)
    }
}

