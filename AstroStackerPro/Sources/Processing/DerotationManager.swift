import CoreMotion
import CoreImage
import Vision

final class DerotationManager {
    private let motion = CMMotionManager()
    private var baseAttitude: CMAttitude?

    func start() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1/30
        motion.startDeviceMotionUpdates()
        baseAttitude = motion.deviceMotion?.attitude.copy() as? CMAttitude
    }

    func stop() {
        motion.stopDeviceMotionUpdates()
        baseAttitude = nil
    }

    /// Restituisce una trasformazione approssimativa basata sul delta di rotazione.
    func transformForCurrentFrame(referenceExtent: CGRect) -> CGAffineTransform {
        guard let base = baseAttitude, let current = motion.deviceMotion?.attitude else {
            return .identity
        }
        // differenza yaw/pitch/roll -> usiamo yaw (rotazione intorno all'asse z) in modo grezzo
        let yawDelta = current.yaw - base.yaw
        return CGAffineTransform(rotationAngle: CGFloat(-yawDelta))
            .translatedBy(x: 0, y: 0) // estendibile per pitch/roll
    }

    /// Rifinitura con Vision translation per ogni frame (usata in AstroCaptureManager)
    static func refineTranslation(base: CIImage, img: CIImage) -> CGAffineTransform {
        let req = VNTranslationalImageRegistrationRequest(targetedCIImage: img, options: [:])
        let handler = VNImageRequestHandler(ciImage: base, options: [:])
        try? handler.perform([req])
        if let obs = req.results?.first as? VNImageTranslationAlignmentObservation {
            return obs.alignmentTransform
        }
        return .identity
    }
}
