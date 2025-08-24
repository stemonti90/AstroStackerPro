import Foundation
import MetricKit

final class MetricKitManager: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricKitManager()

    private override init() {
        super.init()
    }

    func register() {
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            log("metric-\(Date().timeIntervalSince1970).json", data: payload.jsonRepresentation())
        }
    }

    private func didReceive(_ payloads: [MXCrashDiagnostic]) {
        for crash in payloads {
            if let data = try? JSONSerialization.data(withJSONObject: crash.dictionaryRepresentation(), options: []) {
                log("crash-\(Date().timeIntervalSince1970).json", data: data)
            }
        }
    }

    private func log(_ filename: String, data: Data) {
        #if DEBUG
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(filename)
        try? data.write(to: url)
        #endif
        // minimal anonymous log for release
        print("[MetricKit] saved \(filename)")
    }
}
