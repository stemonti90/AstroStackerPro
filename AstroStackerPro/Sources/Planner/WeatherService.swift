import Foundation

struct WeatherData: Codable {
    let clouds: Int    // %
    let visibility: Int
}

final class WeatherService {
    private let key = ProcessInfo.processInfo.environment["OPENWEATHER_KEY"] ?? ""
    func fetch(lat: Double, lon: Double) async -> WeatherData? {
        guard !key.isEmpty else { return nil }
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(key)&units=metric") else {
            return nil
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let clouds = (json?["clouds"] as? [String: Any])?["all"] as? Int ?? 100
            let visibility = json?["visibility"] as? Int ?? 0
            return WeatherData(clouds: clouds, visibility: visibility)
        } catch { return nil }
    }
}
