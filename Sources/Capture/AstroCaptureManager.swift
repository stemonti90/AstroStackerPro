
import Foundation
import AVFoundation
import CoreImage
import Vision
import CoreMotion
import SwiftUI

final class AstroCaptureManager: NSObject, ObservableObject {
    // Stato UI
    @Published var isRunning = false
    @Published var frameCount = 0
    @Published var iso: Float = 400 { didSet { updateExposure() } }
    @Published var exposureDuration: Double = 1/60 { didSet { updateExposure() } }
    @Published var focusPosition: Float = 0.5 { didSet { updateFocus() } }
    @Published var stackingMethod: StackingMethod = .maximum

    // RAW capture
    private let photoOutput = AVCapturePhotoOutput()

    // Buffers
    private var frameBuffer: [CVPixelBuffer] = []
    private let maxFrames = 1200
    private let context = CIContext()

    // Calibrazione
    private var darkCI: CIImage?; private var flatCI: CIImage?; private var biasCI: CIImage?
    private var captureCalibType: CalibrationType?; private var calibEndTime: Date?

    // Motion per derotazione (placeholder)
    private let motionMgr = CMMotionManager()

    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "capture.queue")

    override init() { super.init(); configureSession() }

    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .inputPriority
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)

        let videoOut = AVCaptureVideoDataOutput()
        videoOut.videoSettings = [ (kCVPixelBufferPixelFormatTypeKey as String): kCVPixelFormatType_32BGRA ]
        videoOut.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(videoOut) { session.addOutput(videoOut) }

        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        photoOutput.isHighResolutionCaptureEnabled = true

        session.commitConfiguration()
    }

    func start() {
        queue.async {
            if !self.session.isRunning {
                self.frameBuffer.removeAll(); self.frameCount = 0
                self.session.startRunning()
                DispatchQueue.main.async { self.isRunning = true }
            }
        }
        startMotion()
    }

    func stop() {
        queue.async {
            if self.session.isRunning {
                self.session.stopRunning()
                DispatchQueue.main.async { self.isRunning = false }
            }
        }
        stopMotion()
    }

    // MARK: - RAW capture
    func captureRAW(format: RAWFormat, completion: @escaping ()->Void) {
        let settings: AVCapturePhotoSettings
        if format == .proraw, photoOutput.isProRAWEnabled {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            settings.isHighResolutionPhotoEnabled = true
            settings.isDepthDataDeliveryEnabled = false
            settings.isPortraitEffectsMatteDeliveryEnabled = false
            settings.embedsThumbnailPixelBuffer = true
            settings.photoQualityPrioritization = .quality
            settings.rawPhotoPixelFormatType = kCVPixelFormatType_14Bayer_GRBG
        } else {
            settings = AVCapturePhotoSettings(rawPixelFormatType: kCVPixelFormatType_14Bayer_GRBG)
        }
        photoOutput.capturePhoto(with: settings, delegate: RAWPhotoDelegate(done: completion))
    }

    // MARK: - Calibrazione
    func captureCalibration(_ type: CalibrationType, seconds: Int) {
        captureCalibType = type
        calibEndTime = Date().addingTimeInterval(Double(seconds))
    }

    // MARK: - Processing
    func processFrames(applyLightPollution: Bool) -> UIImage? {
        guard !frameBuffer.isEmpty else { return nil }
        let ciFrames = frameBuffer.map { CIImage(cvPixelBuffer: $0) }
        guard let base = ciFrames.first else { return nil }

        var aligned: [CIImage] = [base]
        if ciFrames.count > 1 {
            for img in ciFrames.dropFirst() {
                let req = VNTranslationalImageRegistrationRequest(targetedCIImage: img, options: [:])
                let handler = VNImageRequestHandler(ciImage: base, options: [:])
                try? handler.perform([req])
                if let obs = req.results?.first as? VNImageTranslationAlignmentObservation {
                    aligned.append(img.transformed(by: obs.alignmentTransform))
                } else { aligned.append(img) }
            }
        }

        // TODO: derotazione usando motionMgr data
        // TODO: sottrazione dark/flat/bias

        let result: CIImage
        switch stackingMethod {
        case .maximum:
            result = aligned.dropFirst().reduce(base) { acc, next in next.composited(over: acc) }
        case .average:
            let sum = aligned.reduce(CIImage(color: .clear)) { acc, next in
                next.applyingFilter("CIAdditionCompositing", parameters: ["inputBackgroundImage": acc])
            }
            let d = Float(aligned.count)
            result = sum.applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: 1/d, y:0,z:0,w:0),
                "inputGVector": CIVector(x:0,y:1/d,z:0,w:0),
                "inputBVector": CIVector(x:0,y:0,z:1/d,w:0),
                "inputAVector": CIVector(x:0,y:0,z:0,w:1)
            ])
        }
        var final = result
        if applyLightPollution {
            final = final.applyingFilter("CITemperatureAndTint", parameters: ["inputNeutral": CIVector(x:6500,y:0),"inputTargetNeutral": CIVector(x:5000,y:0)])
        }
        guard let cg = context.createCGImage(final, from: final.extent) else { return nil }
        return UIImage(cgImage: cg)
    }

    // MARK: - Exposure/Focus
    private func updateExposure() {
        queue.async {
            guard let d = self.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else { return }
            do {
                try d.lockForConfiguration()
                let dur = CMTimeMakeWithSeconds(self.exposureDuration, preferredTimescale: 1_000_000)
                d.setExposureModeCustom(duration: dur, iso: self.iso, completionHandler: nil)
                d.unlockForConfiguration()
            } catch { }
        }
    }

    private func updateFocus() {
        queue.async {
            guard let d = self.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first?.device else { return }
            do {
                try d.lockForConfiguration()
                if d.isFocusModeSupported(.locked) {
                    d.setFocusModeLocked(lensPosition: self.focusPosition, completionHandler: nil)
                }
                d.unlockForConfiguration()
            } catch { }
        }
    }

    // MARK: - Motion
    private func startMotion() {
        guard motionMgr.isDeviceMotionAvailable else { return }
        motionMgr.deviceMotionUpdateInterval = 1/30
        motionMgr.startDeviceMotionUpdates()
    }
    private func stopMotion() { motionMgr.stopDeviceMotionUpdates() }
}

extension AstroCaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Se in calibrazione, smista
        if let type = captureCalibType, let end = calibEndTime {
            if Date() <= end {
                switch type {
                case .dark: /* TODO: accumula dark */ break
                case .flat: /* TODO */ break
                case .bias: /* TODO */ break
                }
                return
            } else {
                captureCalibType = nil; calibEndTime = nil
            }
        }

        if frameBuffer.count >= maxFrames {
            frameBuffer.removeFirst(frameBuffer.count - maxFrames + 1)
        }
        frameBuffer.append(pb)
        DispatchQueue.main.async { self.frameCount = self.frameBuffer.count }
    }
}
