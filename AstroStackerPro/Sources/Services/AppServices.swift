//
//  AppServices.swift
//  AstroStackerPro
//
//  iOS 17+ – Bridge servizi + compatibilità con vecchio AstroService.compute(...)
//

import SwiftUI
import CoreImage

// MARK: - Dati astronomici minimi per il Planner
public struct AstroData {
    /// Illuminazione fra 0.0 (novilunio) e 1.0 (plenilunio)
    public let moonIllumination: Double
}

@MainActor
final class AppServices: ObservableObject {
    // Unica istanza del capture manager usata in tutta l’app (MainActor)
    let captureManager: AstroCaptureManager

    // Bridge esposti alla UI
    @Published var capture: CaptureBridge
    @Published var editor: EditorBridge

    init() {
        self.captureManager = AstroCaptureManager()
        self.capture = CaptureBridge(manager: captureManager)
        self.editor  = EditorBridge()
    }
}

// MARK: - Bridge per la schermata di cattura
@MainActor
final class CaptureBridge: ObservableObject {
    private let manager: AstroCaptureManager

    @Published var isRecording: Bool = false
    @Published var exposure: Double = 4
    @Published var iso: Double = 800
    @Published var frames: Int = 40
    @Published var useProRAW: Bool = true

    init(manager: AstroCaptureManager) {
        self.manager = manager
    }

    func start() {
        manager.startCapture(frames: frames)
        isRecording = true
    }

    func stop() {
        // Quando verrà esposto uno stopCapture() nel manager, richiamarlo qui.
        isRecording = false
    }
}

// MARK: - Bridge per la schermata di editor
final class EditorBridge: ObservableObject {
    @Published var denoise: Double = 0.35
    @Published var sharpen: Double = 0.4
    @Published var saturation: Double = 1.0  // non applicato in questa build base

    /// Applica regolazioni al volo su CIImage
    func applyAdjustments(to image: CIImage) -> CIImage {
        AIDenoiser.shared.denoise(
            image: image,
            noiseLevel: Float(denoise),
            sharpness: Float(sharpen)
        )
    }
}

// MARK: - Compatibilità con vecchio AstroService.compute(...)
extension AppServices {
    /// Calcolo rapido dell'illuminazione lunare (0...1) usando la fase sinodica.
    /// Restituisce `AstroData` compatibile con il vecchio planner.
    func compute(for date: Date, lat: Double, lon: Double) -> AstroData {
        // Epoca di riferimento nota (novilunio): 2000-01-06 18:14 UTC
        var ref = DateComponents()
        ref.year = 2000; ref.month = 1; ref.day = 6
        ref.hour = 18; ref.minute = 14
        ref.timeZone = TimeZone(secondsFromGMT: 0)
        let refDate = Calendar(identifier: .gregorian).date(from: ref) ?? Date(timeIntervalSince1970: 947_116_040)

        let synodic: Double = 29.53058867 // giorni
        let days = date.timeIntervalSince(refDate) / 86_400.0
        let phase = days.truncatingRemainder(dividingBy: synodic)
        let illum = 0.5 * (1.0 - cos(2.0 * .pi * (phase / synodic))) // 0..1

        return AstroData(moonIllumination: max(0, min(1, illum)))
    }
}

