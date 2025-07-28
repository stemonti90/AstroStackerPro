
import Foundation
import SwiftUI

enum RAWFormat: String, CaseIterable, Identifiable { case raw, proraw; var id: String { rawValue } }

enum CalibrationType { case dark, flat, bias }

