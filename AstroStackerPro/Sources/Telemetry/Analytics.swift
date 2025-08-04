import Foundation
import FirebaseAnalytics

struct Analytics {
    static func log(_ event: String, params: [String: Any]? = nil) {
        FirebaseAnalytics.Analytics.logEvent(event, parameters: params)
    }
}
