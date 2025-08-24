//
//  CalibrationManager.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 16/08/25.
//


import Foundation
import CoreImage

/// Gestisce l’acquisizione/creazione dei master frames (dark, flat, bias).
@MainActor
final class CalibrationManager {

    enum CalibType { case dark, flat, bias }

    private var frames: [CIImage] = []

    func reset() {
        frames.removeAll()
    }

    /// Avvia una sessione di calibrazione “semplificata”.
    /// In questa implementazione placeholder, richiama subito la completion
    /// con un’immagine neutra 1x1 per garantire la compilazione.
    func start(_ type: CalibType, duration: TimeInterval = 0, completion: @escaping (CIImage) -> Void) {
        frames.removeAll()
        let color = CIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let img = CIImage(color: color).cropped(to: CGRect(x: 0, y: 0, width: 1, height: 1))
        completion(img)
    }
}
