//
//  EngagementManager.swift
//  AstroStackerPro
//
//  Created by Stefano Monticciolo on 16/08/25.
//


import Foundation
import StoreKit
import UIKit

/// Servizi di "engagement" usati nella SettingsView (apertura link, review, share).
@MainActor
final class EngagementManager: ObservableObject {

    static let shared = EngagementManager()
    private override init() {}

    // Richiesta di review nativa
    func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    // Apertura URL sicura
    func openURL(_ url: URL?) {
        guard let url else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    // Comodità: apertura da stringa
    func openURLString(_ string: String) {
        openURL(URL(string: string))
    }

    // Condivisione testo/link
    func share(text: String) {
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.topMostViewController()?.present(av, animated: true)
    }
}

// MARK: - Helpers
private extension UIApplication {
    func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow?.rootViewController }.first) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            return topMostViewController(base: tab.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}
