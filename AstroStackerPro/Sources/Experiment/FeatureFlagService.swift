import Foundation
import FirebaseRemoteConfig

final class FeatureFlagService {
    static let shared = FeatureFlagService()
    private let remoteConfig = RemoteConfig.remoteConfig()

    private init() {
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(["paywall_layout": "A" as NSObject,
                                  "denoise_strength_default": 0.5 as NSObject,
                                  "planner_formula": "v1" as NSObject])
        fetch()
    }

    func fetch() {
        remoteConfig.fetch { [weak self] status, _ in
            if status == .success {
                self?.remoteConfig.activate(completion: nil)
            }
        }
    }

    func getBool(_ key: String) -> Bool {
        remoteConfig[key].boolValue
    }

    func getFloat(_ key: String) -> Float {
        remoteConfig[key].numberValue?.floatValue ?? 0
    }

    func variant(_ key: String) -> String {
        remoteConfig[key].stringValue ?? ""
    }
}
