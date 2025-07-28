
import Foundation
import UIKit
import CoreImage

final class EditorViewModel: ObservableObject {
    @Published var preview: UIImage?
    @Published var exposure: Double = 0 { didSet { applyBasicAdjustments() } }
    @Published var contrast: Double = 0 { didSet { applyBasicAdjustments() } }

    private let ctx = CIContext()
    private var original: CIImage?

    func load(image: UIImage) {
        original = CIImage(image: image)
        preview = image
    }

    private func applyBasicAdjustments() {
        guard let original else { return }
        var img = original
        img = img.applyingFilter("CIExposureAdjust", parameters: ["inputEV": exposure])
        img = img.applyingFilter("CIColorControls", parameters: ["inputContrast": contrast + 1])
        if let cg = ctx.createCGImage(img, from: img.extent) { preview = UIImage(cgImage: cg) }
    }

    func applyStarBoost() {
        // TODO: maschera stelle + sharpen
    }
}
