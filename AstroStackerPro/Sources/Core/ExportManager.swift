//
//  ExportManager.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 10/08/25.
//


import Photos
import CoreImage
import UIKit

@MainActor
final class ExportManager {
    static let shared = ExportManager()
    private let context = CIContext()

    /// Salva un'immagine in HEIF + JPEG nella libreria Foto
    func saveToPhotos(_ image: CIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("❌ Permesso Foto non concesso")
                return
            }
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()

                // JPEG
                if let jpegData = self.context.jpegRepresentation(of: image,
                                                                  colorSpace: CGColorSpaceCreateDeviceRGB()) {
                    request.addResource(with: .photo, data: jpegData, options: nil)
                }

                // HEIF
                if let heifData = self.context.heifRepresentation(of: image,
                                                                  format: .RGBA8,
                                                                  colorSpace: CGColorSpaceCreateDeviceRGB(),
                                                                  options: [:]) {
                    request.addResource(with: .photo, data: heifData, options: nil)
                }
            } completionHandler: { success, error in
                if success {
                    print("✅ Export completato con successo")
                } else {
                    print("❌ Export fallito: \(error?.localizedDescription ?? "sconosciuto")")
                }
            }
        }
    }
}
