
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

        // Salva anche su iCloud Drive se disponibile
        if FileManager.default.ubiquityIdentityToken != nil,
           let ubiURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents/") {
            let name = UUID().uuidString
            let fileURL = ubiURL.appendingPathComponent(name).appendingPathExtension("dng")
            try? FileManager.default.createDirectory(at: ubiURL, withIntermediateDirectories: true)
            try? data.write(to: fileURL)

            // Metadata JSON di supporto
            if let jsonData = try? JSONSerialization.data(withJSONObject: photo.metadata, options: .prettyPrinted) {
                let jsonURL = fileURL.deletingPathExtension().appendingPathExtension("json")
                try? jsonData.write(to: jsonURL)
            }
        }
    }
}
