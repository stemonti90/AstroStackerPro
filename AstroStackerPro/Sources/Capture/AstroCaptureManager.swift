import Foundation
import AVFoundation
import CoreImage
import SwiftUI

/// Manager della sessione camera e del processing di base.
/// È isolato sul MainActor: qualsiasi accesso a `session`, `frameBuffer`,
/// `isRunning`, `frameCount` deve avvenire sul main.
@MainActor
final class AstroCaptureManager: NSObject, ObservableObject {

    // MARK: - UI state
    @Published var isRunning = false
    @Published var frameCount = 0

    // MARK: - Buffer
    private var frameBuffer: [CVPixelBuffer] = []

    /// Override impostabile dal bridge (es. AppServices) per scegliere
    /// quanti frame accumulare prima dello stacking.
    private var maxFramesOverride: Int? = nil

    /// Limite effettivo dei frame nel buffer.
    private var maxFrames: Int {
        maxFramesOverride ?? HardwareCapabilities.recommendedMaxFrames
    }

    // MARK: - Calibration/master frames
    private var darkCI: CIImage?
    private var flatCI: CIImage?
    private var biasCI: CIImage?
    private let calibrationManager = CalibrationManager()

    // MARK: - Engines
    private let registration = StarRegistration()
    private let stackEngine = StackEngine()

    // MARK: - Capture session
    private let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "capture.queue")

    // MARK: - Accessori per la UI di anteprima
    /// Espone la sessione per i layer/preview della UI (es. AVCaptureVideoPreviewLayer).
    var sessionForPreview: AVCaptureSession { session }

    /// Configura (già fatto in init) e avvia la sessione se non è in esecuzione.
    /// Usato da CaptureScreen.onAppear().
    func configureAndStartIfNeeded() {
        if !session.isRunning {
            start()
        }
    }

    // MARK: - Init
    override init() {
        super.init()
        configureSession()
    }

    // MARK: - Session configuration
    private func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = HardwareCapabilities.recommendedSessionPreset

        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else {
            session.commitConfiguration()
            return
        }
        session.addInput(input)

        // Video output per anteprima/accumulo
        let videoOut = AVCaptureVideoDataOutput()
        videoOut.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        videoOut.alwaysDiscardsLateVideoFrames = true
        videoOut.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(videoOut) { session.addOutput(videoOut) }

        // Photo output (RAW/HEVC) — se/quando servirà
        let photoOut = AVCapturePhotoOutput()
        if session.canAddOutput(photoOut) { session.addOutput(photoOut) }
        if #available(iOS 16.0, *) {
            photoOut.maxPhotoQualityPrioritization = .quality
        } else {
            photoOut.isHighResolutionCaptureEnabled = true
        }

        session.commitConfiguration()
    }

    // MARK: - API bridge per AppServices

    /// Chiamata dal bridge: imposta il numero di frame target e avvia la sessione.
    func startCapture(frames: Int) {
        maxFramesOverride = max(1, frames)
        start()
    }

    /// Alias comodo per il bridge.
    func stopCapture() {
        stop()
    }

    // MARK: - Start/Stop di base
    func start() {
        queue.async { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                if !self.session.isRunning {
                    self.frameBuffer.removeAll()
                    self.frameCount = 0
                    self.session.startRunning()
                    self.isRunning = true
                }
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            Task { @MainActor in
                if self.session.isRunning {
                    self.session.stopRunning()
                    self.isRunning = false
                }
            }
        }
    }

    // MARK: - Processing chiamato dalla UI
    /// Esegue calibrazione base + (opzionale) filtro inquinamento + stacking.
    func processFrames(applyLightPollution: Bool) -> CIImage? {
        let buffers = frameBuffer
        guard !buffers.isEmpty else { return nil }

        var images = buffers.map { CIImage(cvPixelBuffer: $0) }

        // Calibrazione semplice
        images = images.map(applyCalibration(to:))

        // Registrazione stelle (placeholder: passthrough)
        images = registration.align(images)

        // Stacking
        return stackEngine.stack(images, strategy: ImageStackingStrategy.median)
    }

    // MARK: - Calibration helpers
    private func applyCalibration(to image: CIImage) -> CIImage {
        var out = image
        if let bias = biasCI, let f = CIFilter(name: "CISubtractBlendMode") {
            f.setValue(out, forKey: kCIInputImageKey)
            f.setValue(bias, forKey: kCIInputBackgroundImageKey)
            out = f.outputImage ?? out
        }
        if let dark = darkCI, let f = CIFilter(name: "CISubtractBlendMode") {
            f.setValue(out, forKey: kCIInputImageKey)
            f.setValue(dark, forKey: kCIInputBackgroundImageKey)
            out = f.outputImage ?? out
        }
        if let flat = flatCI, let f = CIFilter(name: "CIDivideBlendMode") {
            f.setValue(out, forKey: kCIInputImageKey)
            f.setValue(flat, forKey: kCIInputBackgroundImageKey)
            out = f.outputImage ?? out
        }
        return out
    }
}

// MARK: - Delegati Capture
extension AstroCaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {

    /// Delegate nonisolated → hop esplicito al MainActor prima di toccare lo stato.
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        Task { @MainActor in
            // Limita la lunghezza del buffer
            if self.frameBuffer.count >= self.maxFrames {
                self.frameBuffer.removeFirst(self.frameBuffer.count - self.maxFrames + 1)
            }
            self.frameBuffer.append(pb)
            self.frameCount = self.frameBuffer.count
        }
    }
}

