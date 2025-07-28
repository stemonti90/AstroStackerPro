
import Foundation
import AVFoundation
import CoreImage
import Vision
import SwiftUI

enum StackingMethod: String, CaseIterable, Identifiable {
    case maximum, average
    var id: String { rawValue }
}

final class AstroCaptureManager: NSObject, ObservableObject {
    @Published var isRunning = false
    @Published var frameCount: Int = 0
    @Published var iso: Float = 400 { didSet { updateExposure() } }
    @Published var exposureDuration: Double = 1/60 { didSet { updateExposure() } }
    @Published var focusPosition: Float = 0.5 { didSet { updateFocus() } }
    @Published var stackingMethod: StackingMethod = .maximum

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "capture.queue")
    private var frameBuffer: [CVPixelBuffer] = []
    private let maxFrames = 1200
    private let context = CIContext()

    override init() {
        super.init()
        configure()
    }

    private func configure() {
        session.beginConfiguration()
        session.sessionPreset = .inputPriority

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else { return }

        session.addInput(input)

        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [ (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA ]
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }

        if let conn = output.connection(with: .video) {
            conn.videoOrientation = .portrait
        }

        session.commitConfiguration()
    }

    func start() {
        queue.async {
            if !self.session.isRunning {
                self.frameBuffer.removeAll()
                self.frameCount = 0
                self.session.startRunning()
                DispatchQueue.main.async { self.isRunning = true }
            }
        }
    }

    func stop() {
        queue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async { self.isRunning = false }
            }
        }
    }

    func processFrames(applyLightPollution: Bool) -> UIImage? {
        guard !frameBuffer.isEmpty else { return nil }
        let ciFrames: [CIImage] = frameBuffer.map { CIImage(cvPixelBuffer: $0) }
        guard let base = ciFrames.first else { return nil }

        var aligned = [base]
        if ciFrames.count > 1 {
            for img in ciFrames.dropFirst() {
                let req = VNTranslationalImageRegistrationRequest(targetedCIImage: img, options: [:])
                let handler = VNImageRequestHandler(ciImage: base, options: [:])
                try? handler.perform([req])
                if let obs = req.results?.first as? VNImageTranslationAlignmentObservation {
                    let t = CGAffineTransform(translationX: obs.alignmentTransform.tx, y: obs.alignmentTransform.ty)
                    aligned.append(img.transformed(by: t))
                } else {
                    aligned.append(img)
                }
            }
        }

        let result: CIImage
        switch stackingMethod {
        case .maximum:
            result = aligned.dropFirst().reduce(base) { acc, next in
                next.composited(over: acc)
            }
        case .average:
            let sum = aligned.reduce(CIImage(color: .clear)) { acc, next in
                next.applyingFilter("CIAdditionCompositing", parameters: ["inputBackgroundImage": acc])
            }
            let divisor = Float(aligned.count)
            result = sum.applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 1/divisor, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: 1/divisor, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: 1/divisor, w: 0),
                "inputAVector": CIVector(x: 0, y: 0, z: 0, w: 1)
            ])
        }

        var final = result
        if applyLightPollution {
            final = final.applyingFilter("CITemperatureAndTint", parameters: [
                "inputNeutral": CIVector(x: 6500, y: 0),
                "inputTargetNeutral": CIVector(x: 5000, y: 0)
            ])
        }

        guard let cg = context.createCGImage(final, from: final.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    private func updateExposure() {
        queue.async {
            guard let device = self.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else { return }
            do {
                try device.lockForConfiguration()
                let duration = CMTimeMakeWithSeconds(self.exposureDuration, preferredTimescale: 1_000_000)
                device.setExposureModeCustom(duration: duration, iso: self.iso, completionHandler: nil)
                device.unlockForConfiguration()
            } catch { }
        }
    }

    private func updateFocus() {
        queue.async {
            guard let device = self.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else { return }
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(.locked) {
                    device.setFocusModeLocked(lensPosition: self.focusPosition, completionHandler: nil)
                }
                device.unlockForConfiguration()
            } catch { }
        }
    }
}

extension AstroCaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        if frameBuffer.count >= maxFrames {
            frameBuffer.removeFirst(frameBuffer.count - maxFrames + 1)
        }
        frameBuffer.append(pb)
        DispatchQueue.main.async { self.frameCount = self.frameBuffer.count }
    }
}
