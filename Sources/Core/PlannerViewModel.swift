
import Foundation
import Combine

final class PlannerViewModel: ObservableObject {
    @Published var nights: [NightPlan] = []
    func refresh() {
        // TODO: integrare SwiftAA + API meteo. Placeholder.
        let today = Date()
        nights = (0..<7).map { i in
            NightPlan(date: Calendar.current.date(byAdding: .day, value: i, to: today)!, score: Double.random(in: 0.3...0.95))
        }
    }
}
