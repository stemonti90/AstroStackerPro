import Foundation
import UIKit

final class CloudExporter {
    static func export(_ data: Data, fileName: String, toICloud: Bool, completion: @escaping (URL?)->Void) {
        let fm = FileManager.default
        if toICloud, let ubiq = fm.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
            let url = ubiq.appendingPathComponent(fileName)
            try? fm.createDirectory(at: ubiq, withIntermediateDirectories: true)
            do { try data.write(to: url); completion(url) } catch { completion(nil) }
        } else {
            // fallback: temp url (ShareSheet handled in UI layer)
            let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
            do { try data.write(to: url); completion(url) } catch { completion(nil) }
        }
    }
}
