import AVFoundation
import Photos
import UIKit

final class RAWPhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let done: () -> Void

    init(done: @escaping () -> Void) {
        self.done = done
        super.init()
    }

    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        defer { done() }

        // Errori di cattura
        if let error = error {
            print("RAW capture error:", error.localizedDescription)
            return
        }

        // DNG (o HEIF/JPEG se non RAW)
        guard let data = photo.fileDataRepresentation() else {
            print("fileDataRepresentation() nil")
            return
        }

        // (Opzionale) Thumbnail/anteprima — con SDK recenti è direttamente CGImage?
        if let cgPreview = photo.previewCGImageRepresentation() {
            let _ = UIImage(cgImage: cgPreview)
            // Se vuoi, qui puoi pubblicare una notifica o aggiornare un'anteprima in UI.
        }

        // Salvataggio in Photos (richiede NSPhotoLibraryAddUsageDescription in Info.plist)
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else {
                print("Photo Library not authorized")
                return
            }
            PHPhotoLibrary.shared().performChanges({
                let req = PHAssetCreationRequest.forAsset()
                let opts = PHAssetResourceCreationOptions()

                // Nome file leggibile in Foto/Files
                let ts = ISO8601DateFormatter().string(from: Date())
                opts.originalFilename = "Astro_\(ts).dng"

                // Per un DNG va bene .photo; in alternativa .fullSizePhoto
                req.addResource(with: .photo, data: data, options: opts)
            }, completionHandler: { success, err in
                if let err = err { print("Photos save error:", err.localizedDescription) }
            })
        }
    }

    // Facoltativo: callback finale a cattura completata (utile per cleanup)
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        if let error = error {
            print("didFinishCaptureFor error:", error.localizedDescription)
        }
        // done() è già chiamato in defer sopra; qui non serve
    }
}

