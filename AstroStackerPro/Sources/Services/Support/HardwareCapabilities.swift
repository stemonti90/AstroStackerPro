//
//  HardwareCapabilities.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 16/08/25.
//


import Foundation
import UIKit
import AVFoundation

/// Heuristics sulle capacità del device per scegliere preset e limiti sicuri.
struct HardwareCapabilities {

    /// Considera “alta gamma” se > 4 core attivi (euristica semplice).
    static var isHighEnd: Bool {
        ProcessInfo.processInfo.activeProcessorCount > 4
    }

    /// Preset raccomandato per la sessione video.
    static var recommendedSessionPreset: AVCaptureSession.Preset {
        isHighEnd ? .photo : .hd1280x720
    }

    /// Numero massimo di frame da accumulare nello stack.
    static var recommendedMaxFrames: Int {
        isHighEnd ? 60 : 24
    }
}
