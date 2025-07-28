
import AVFoundation
import Photos
import MobileCoreServices

final class RAWPhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let done: ()->Void
    init(done: @escaping ()->Void) { self.done = done }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        defer { done() }
        guard error == nil else { return }
        guard let data = photo.fileDataRepresentation() else { return }

        // Salva in Libreria Foto
        PHPhotoLibrary.shared().performChanges({
            let req = PHAssetCreationRequest.forAsset()
            let options = PHAssetResourceCreationOptions()
            req.addResource(with: .photo, data: data, options: options)
        }, completionHandler: nil)

        // Salva anche su iCloud Drive se disponibile (metadata TODO)
        CloudExporter.export(data, fileName: UUID().uuidString + ".dng", toICloud: FileManager.default.ubiquityIdentityToken != nil) { url in
            if let url, let json = try? JSONSerialization.data(withJSONObject: photo.metadata, options: .prettyPrinted) {
                let metaURL = url.deletingPathExtension().appendingPathExtension("json")
                try? json.write(to: metaURL)
            }
        }
    }
}
