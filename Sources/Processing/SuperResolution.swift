
import CoreML
import CoreImage

final class SuperResolution {
    private lazy var model: MLModel? = {
        guard let url = Bundle.main.url(forResource: "SuperRes", withExtension: "mlmodelc") else { return nil }
        return try? MLModel(contentsOf: url)
    }()

    func upscale2x(_ image: CIImage) -> CIImage {
        guard let model else { return image }
        let input = try? MLDictionaryFeatureProvider(dictionary: ["image": MLFeatureValue(pixelBuffer: pixelBuffer(from: image))])
        if let out = try? model.prediction(from: input!), let pb = out.featureValue(for: "outputImage")?.imageBufferValue {
            return CIImage(cvPixelBuffer: pb)
        }
        return image
    }

    private func pixelBuffer(from image: CIImage) -> CVPixelBuffer {
        var pb: CVPixelBuffer?
        let attrs: [CFString: Any] = [kCVPixelBufferCGImageCompatibilityKey: true,
                                      kCVPixelBufferCGBitmapContextCompatibilityKey: true]
        CVPixelBufferCreate(kCFAllocatorDefault, Int(image.extent.width), Int(image.extent.height), kCVPixelFormatType_32BGRA, attrs as CFDictionary, &pb)
        if let pb { CIContext().render(image, to: pb) }
        return pb!
    }
}
