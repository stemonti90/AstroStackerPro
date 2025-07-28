
import Foundation
import SwiftUI

enum RAWFormat: String, CaseIterable, Identifiable { case raw, proraw; var id: String { rawValue } }

enum CalibrationType { case dark, flat, bias }

struct NightPlan: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double // 0-1
    var scoreLabel: String { String(format: "%.0f%%", score*100) }
}
