//
//  StackingPipeline.swift
//  AstroStackerPro
//

import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import Photos
import UIKit

@MainActor
final class StackingPipeline: ObservableObject {
    static let shared = StackingPipeline()
    private let context = CIContext()

    // Anteprima per l’editor/galleria
    @Published var lastResult: CIImage?

    /// Stacking (media semplice) + denoise opzionale
    func processStack(from photos: [AVCapturePhoto], applyDenoise: Bool = true) async -> CIImage? {
        guard !photos.isEmpty else { return nil }

        // Converti in CIImage
        var ciImages: [CIImage] = []
        ciImages.reserveCapacity(photos.count)
        for p in photos {
            if let data = p.fileDataRepresentation(), let ci = CIImage(data: data) {
                ciImages.append(ci)
            }
        }
        guard let first = ciImages.first else { return nil }

        // Render raw bytes di ogni frame e fai media
        let w = Int(first.extent.width)
        let h = Int(first.extent.height)
        var acc = [Float](repeating: 0, count: w * h * 4)

        for img in ciImages {
            guard let cg = context.createCGImage(img, from: img.extent),
                  let providerData = cg.dataProvider?.data,
                  let ptr = CFDataGetBytePtr(providerData) else { continue }
            let n = w * h * 4
            var i = 0
            while i < n {
                acc[i]   += Float(ptr[i])
                acc[i+1] += Float(ptr[i+1])
                acc[i+2] += Float(ptr[i+2])
                acc[i+3] += Float(ptr[i+3])
                i += 4
            }
        }

        let count = Float(ciImages.count)
        let avgBytes: [UInt8] = acc.map { UInt8(min(max($0 / count, 0), 255)) }
        let cfData = CFDataCreate(nil, avgBytes, avgBytes.count)!
        let provider = CGDataProvider(data: cfData)!
        let cgOut = CGImage(
            width: w, height: h,
            bitsPerComponent: 8, bitsPerPixel: 32, bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue),
            provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent
        )!

        var outCI = CIImage(cgImage: cgOut)

        if applyDenoise {
            outCI = AIDenoiser.shared.denoise(image: outCI, noiseLevel: 0.35, sharpness: 0.4)
        }

        lastResult = outCI
        return outCI
    }

    /// Salva su Foto in HEIF (più leggero) + JPEG di compatibilità
    func exportToPhotos(ciImage: CIImage) {
        guard let cg = context.createCGImage(ciImage, from: ciImage.extent) else { return }
        let ui = UIImage(cgImage: cg)

        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("❌ Accesso Foto negato"); return
            }
            PHPhotoLibrary.shared().performChanges({
                let req = PHAssetCreationRequest.forAsset()
                if let heif = ui.heifData() {
                    req.addResource(with: .photo, data: heif, options: nil)
                }
                if let jpg = ui.jpegData(compressionQuality: 0.95) {
                    req.addResource(with: .photo, data: jpg, options: nil)
                }
            }) { ok, err in
                print(ok ? "✅ Stack salvato su Foto" : "❌ Export fallito: \(err?.localizedDescription ?? "-")")
            }
        }
    }
}

// MARK: - UIImage -> HEIF helper
private extension UIImage {
    func heifData(compressionQuality: CGFloat = 0.95) -> Data? {
        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, AVFileType.heic as CFString, 1, nil),
              let cg = self.cgImage else { return nil }
        let opts: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: compressionQuality]
        CGImageDestinationAddImage(dest, cg, opts as CFDictionary)
        CGImageDestinationFinalize(dest)
        return data as Data
    }
}
