import Foundation
import CoreLocation

final class LightPollutionService {
    /// Placeholder: carica un GeoJSON locale e restituisce un indice 0-1
    func score(for location: CLLocationCoordinate2D) -> Double {
        // TODO: parse Docs/LightPollution.geojson and compute SQM. For now random-ish placeholder.
        return 0.5
    }
}
