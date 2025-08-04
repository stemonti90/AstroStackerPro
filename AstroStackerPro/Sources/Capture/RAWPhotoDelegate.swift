
import AVFoundation
import Photos
import UIKit

final class RAWPhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let done: ()->Void
    init(done: @escaping ()->Void) { self.done = done }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer { done() }
        guard error == nil else { return }
        guard let data = photo.fileDataRepresentation() else { return }

        // Thumbnail non più incorporato: ricaviamo eventuale preview dal delegate.
        if let cgPreview = photo.previewCGImageRepresentation()?.takeUnretainedValue() {
            _ = UIImage(cgImage: cgPreview) // eventualmente usabile dalla UI
        }

        // Salva in Libreria Foto
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            req.addResource(with: .photo, data: data, options: options)
        }, completionHandler: nil)

        // Salva anche su iCloud Drive se disponibile insieme ai metadati
        CloudExporter.export(data, fileName: UUID().uuidString + ".dng", toICloud: FileManager.default.ubiquityIdentityToken != nil) { url in
            if let url, let json = try? JSONSerialization.data(withJSONObject: photo.metadata, options: .prettyPrinted) {
                let metaURL = url.deletingPathExtension().appendingPathExtension("json")
                try? json.write(to: metaURL)
            }
        }
    }
}
