import CoreML
import CoreImage

final class SuperResolution {
    static let shared = SuperResolution()
    private let context = CIContext()
    private var model: MLModel?

    private init() {
        if let url = Bundle.main.url(forResource: "SwinIRx2", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: url)
        }
    }

    func upscale2x(_ image: CIImage) -> CIImage {
        guard let model else { return image }
        do {
            let cg = context.createCGImage(image, from: image.extent)!
            let fv = try MLFeatureValue(cgImage: cg, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil)
            let key = model.modelDescription.inputDescriptionsByName.keys.first!
            let provider = try MLDictionaryFeatureProvider(dictionary: [key: fv])
            let out = try model.prediction(from: provider)
            let outKey = model.modelDescription.outputDescriptionsByName.keys.first!
            if let buf = out.featureValue(for: outKey)?.imageBufferValue {
                return CIImage(cvPixelBuffer: buf)
            }
        } catch { }
        return image
    }
}
