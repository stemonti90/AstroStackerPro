import Foundation
import CoreLocation
import Combine

struct NightPlan: Identifiable {
    let id = UUID()
    let date: Date
    let score: Double // 0-1
    let moonIllum: Double
    let clouds: Int
    let note: String
}

final class PlannerViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var nights: [NightPlan] = []
    private let astro = AstroService()
    private let weather = WeatherService()
    private let lp = LightPollutionService()
    private let locMgr = CLLocationManager()

    override init() {
        super.init()
        locMgr.delegate = self
    }

    func refresh() {
        locMgr.requestWhenInUseAuthorization()
        locMgr.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        Task { await computePlans(lat: loc.coordinate.latitude, lon: loc.coordinate.longitude) }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // fallback Milano
        Task { await computePlans(lat: 45.4642, lon: 9.1900) }
    }

    private func computePlans(lat: Double, lon: Double) async {
        var result: [NightPlan] = []
        let baseDate = Date()
        let lpScore = lp.score(for: .init(latitude: lat, longitude: lon))

        for i in 0..<7 {
            let d = Calendar.current.date(byAdding: .day, value: i, to: baseDate)!
            let astroData = astro.compute(for: d, lat: lat, lon: lon)
            let wData = await weather.fetch(lat: lat, lon: lon)

            let cloudPerc = wData?.clouds ?? 100
            // score semplice: meno nuvole, poca luna, buon LP
            let score = max(0, 1 - (astroData.moonIllumination*0.5) - Double(cloudPerc)/200 - (1-lpScore)*0.3 )
            let note = "Luna: \(Int(astroData.moonIllumination*100))%  Nuvole: \(cloudPerc)%  LP: \(Int(lpScore*100))%"
            result.append(NightPlan(date: d, score: score, moonIllum: astroData.moonIllumination, clouds: cloudPerc, note: note))
        }
        DispatchQueue.main.async { self.nights = result.sorted(by: { $0.score > $1.score }) }
    }
}
