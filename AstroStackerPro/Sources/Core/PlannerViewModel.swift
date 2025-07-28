
import Foundation
import Combine
import SwiftAA

final class PlannerViewModel: ObservableObject {
    @Published var nights: [NightPlan] = []
    func refresh() {
        let today = Date()
        nights = (0..<7).compactMap { i in
            guard let date = Calendar.current.date(byAdding: .day, value: i, to: today) else { return nil }
            let sun = Sun(date: date, coordinates: GeographicCoordinates(positivelyWestwardLongitude: 0, latitude: 0))
            let moon = Moon(date: date)
            let moonPhase = moon.phase
            let score = max(0, 1 - abs(moonPhase.phaseAngle.value/180))
            return NightPlan(date: date, score: score)
        }
    }
}
