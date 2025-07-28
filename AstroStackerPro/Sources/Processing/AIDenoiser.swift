import CoreML
import CoreImage

final class AIDenoiser {
    static let shared = AIDenoiser()
    private let context = CIContext()
    private var model: MLModel?

    private init() {
        // Prova a caricare un modello DRUNet/SwinIR convertito in CoreML
        if let url = Bundle.main.url(forResource: "DRUNet", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: url)
        }
    }

    /// Se il modello manca o qualcosa fallisce, ritorna l'immagine originale.
    func denoise(_ image: CIImage, strength: Float) -> CIImage {
        guard let model else { return image }
        do {
            let inputDesc = model.modelDescription.inputDescriptionsByName
            guard let firstKey = inputDesc.keys.first else { return image }
            guard let cg = context.createCGImage(image, from: image.extent) else { return image }
            guard let pixelBuffer = try MLFeatureValue(cgImage: cg, pixelFormatType: kCVPixelFormatType_32BGRA, options: nil).imageBufferValue else { return image }
            let provider = try MLDictionaryFeatureProvider(dictionary: [firstKey: MLFeatureValue(pixelBuffer: pixelBuffer)])
            let out = try model.prediction(from: provider)
            if let outKey = model.modelDescription.outputDescriptionsByName.keys.first,
               let buf = out.featureValue(for: outKey)?.imageBufferValue {
                return CIImage(cvPixelBuffer: buf)
            }
        } catch { }
        return image
    }
}
