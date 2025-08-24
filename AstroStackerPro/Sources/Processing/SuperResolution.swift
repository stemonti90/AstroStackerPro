import CoreML
import CoreImage
import ImageIO

final class SuperResolution {
    static let shared = SuperResolution()
    private let context = CIContext()
    private var model: MLModel?

    private init() {
        if let url = Bundle.main.url(forResource: "SwinIRx2", withExtension: "mlmodelc") {
            model = try? MLModel(contentsOf: url)
        }
    }

    /// Esegue un upscaling 2x via CoreML. Se il modello non è disponibile, restituisce l’immagine originale.
    func upscale2x(_ image: CIImage) -> CIImage {
        guard let model else { return image }

        do {
            guard let cg = context.createCGImage(image, from: image.extent) else { return image }

            // ✅ Inizializzatore corretto: richiede pixelsWide / pixelsHigh
            let fv = try MLFeatureValue(
                cgImage: cg,
                pixelsWide: cg.width,
                pixelsHigh: cg.height,
                pixelFormatType: kCVPixelFormatType_32BGRA,
                options: nil
            )

            // Usa il primo input del modello
            guard let key = model.modelDescription.inputDescriptionsByName.keys.first else { return image }
            let provider = try MLDictionaryFeatureProvider(dictionary: [key: fv])

            // Predizione
            let out = try model.prediction(from: provider)

            // Converte l'output (CVPixelBuffer) in CIImage
            guard let outKey = model.modelDescription.outputDescriptionsByName.keys.first,
                  let buf = out.featureValue(for: outKey)?.imageBufferValue else {
                return image
            }
            return CIImage(cvPixelBuffer: buf)

        } catch {
            // In caso di errore, fallback all’immagine originale
            return image
        }
    }
}

