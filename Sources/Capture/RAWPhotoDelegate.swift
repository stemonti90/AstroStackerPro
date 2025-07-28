
import AVFoundation

final class RAWPhotoDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let done: ()->Void
    init(done: @escaping ()->Void) { self.done = done }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // TODO: salvataggio DNG/ProRAW su Photos/iCloud
        done()
    }
}
