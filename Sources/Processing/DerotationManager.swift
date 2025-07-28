
import CoreImage
import CoreMotion

final class DerotationManager {
    private let motion = CMMotionManager()

    init() { motion.deviceMotionUpdateInterval = 1/30; motion.startDeviceMotionUpdates() }

    func apply(to image: CIImage) -> CIImage {
        guard let dm = motion.deviceMotion else { return image }
        let angle = CGFloat(dm.attitude.yaw)
        return image.transformed(by: CGAffineTransform(rotationAngle: -angle))
    }
}
