import Foundation
import SwiftAA

struct AstroData {
    /// Illuminazione della luna (0-1).
    let moonIllumination: Double
    /// Altitudine della luna espressa in gradi.
    let moonAltitude: Degrees
    /// Orario del tramonto del sole.
    let sunSet: Date
    /// Orario dell'alba.
    let sunRise: Date
}

@MainActor
final class AstroService {
    func compute(for date: Date, lat: Double, lon: Double) -> AstroData {
        let jd = JulianDay(date)
        let eph = Ephemeris(julianDay: jd)
        let moon = eph.moon
        let sun  = eph.sun
        let obs  = GeographicCoordinates(positiveDegrees: lat, longitude: lon)
        let moonIllum = moon.illuminatedFraction
        let moonAlt   = moon.altitude(on: jd, for: obs)
        let rts = sun.riseTransitSet(on: jd, for: obs)
        let sr = rts.rise?.date ?? date
        let ss = rts.set?.date ?? date
        return AstroData(moonIllumination: moonIllum, moonAltitude: moonAlt, sunSet: ss, sunRise: sr)
    }
}
