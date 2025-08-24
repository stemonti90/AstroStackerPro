import Foundation

/// Represents the stacking methods selectable by the user.  This enumeration is
/// exposed to the UI layer and maps to the strategies used by StackEngine.
enum StackingMethod: String, CaseIterable, Codable, Identifiable {
    case average
    case median
    case sigmaClipping
    case percentileClipping
    case hdr
    case maximum

    var id: String { rawValue }

    /// Descrizione leggibile dall'utente.
    var description: String {
        switch self {
        case .average: return NSLocalizedString("Average", comment: "Stacking method")
        case .median: return NSLocalizedString("Median", comment: "Stacking method")
        case .sigmaClipping: return NSLocalizedString("Sigma Clipping", comment: "Stacking method")
        case .percentileClipping: return NSLocalizedString("Percentile Clipping", comment: "Stacking method")
        case .hdr: return NSLocalizedString("HDR", comment: "Stacking method")
        case .maximum: return NSLocalizedString("Maximum", comment: "Stacking method")
        }
    }
}