import Foundation

/// Metodo di stacking dei frame catturati.
enum StackingMethod: String, CaseIterable, Codable {
    case average
    case median
    case sigmaClipping
    case maximum

    /// Descrizione leggibile dall'utente.
    var description: String {
        switch self {
        case .average: return "Average"
        case .median: return "Median"
        case .sigmaClipping: return "Sigma Clipping"
        case .maximum: return "Maximum"
        }
    }
}
