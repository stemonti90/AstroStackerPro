import Foundation
import UIKit
import CoreImage

final class EditorViewModel: ObservableObject {
    @Published var preview: UIImage?
    @Published var exposure: Double = 0 { didSet { render() } }
    @Published var contrast: Double = 0 { didSet { render() } }
    @Published var starBoost: Bool = false { didSet { render() } }

    private let ctx = CIContext()
    private var original: CIImage?

    func load(image: UIImage) {
        original = CIImage(image: image)
        preview = image
    }

    private func render() {
        guard let original else { return }
        var img = original
        img = img.applyingFilter("CIExposureAdjust", parameters: ["inputEV": exposure])
        img = img.applyingFilter("CIColorControls", parameters: ["inputContrast": contrast + 1])

        if starBoost {
            let mask = StarMaskFilter.maskStars(img)
            let sharpen = img.applyingFilter("CISharpenLuminance", parameters: ["inputSharpness": 0.8])
            img = sharpen.applyingFilter("CIBlendWithMask", parameters: ["inputMaskImage": mask, "inputBackgroundImage": img])
        }

        if let cg = ctx.createCGImage(img, from: img.extent) {
            preview = UIImage(cgImage: cg)
        }
    }
}
