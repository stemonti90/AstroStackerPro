
import CoreML
import CoreImage

final class AIDenoiser {
    private lazy var model: MLModel? = {
        guard let url = Bundle.main.url(forResource: "AIDenoise", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    func denoise(_ image: CIImage, strength: Float) -> CIImage {
        guard let model else { return image }
        let input = try? MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(pixelBuffer: pixelBuffer(from: image))])
        if let out = try? model.prediction(from: input!), let pb = out.featureValue(for: "outputImage")?.imageBufferValue {
            return CIImage(cvPixelBuffer: pb)
        }
        return image
    }

    private func pixelBuffer(from image: CIImage) -> CVPixelBuffer {
        let attr: [CFString: Any] = [kCVPixelBufferCGImageCompatibilityKey: true, kCVPixelBufferCGBitmapContextCompatibilityKey: true]
        var pb: CVPixelBuffer?
        CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32BGRA, attr as CFDictionary, &pb)
        if let pb, let ctx = CIContext() as CIContext? { ctx.render(image, to: pb) }
        return pb!
    }
}
