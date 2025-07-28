import Foundation
import SwiftAA

struct AstroData {
    let moonIllumination: Double  // 0-1
    let moonAltitude: Degrees
    let sunSet: Date
    let sunRise: Date
}

final class AstroService {
    func compute(for date: Date, lat: Double, lon: Double) -> AstroData {
        let jd = JulianDay(date)
        let eph = Ephemeris(julianDay: jd)
        let moon = eph.moon
        let sun  = eph.sun
        let obs  = GeographicCoordinates(positiveDegrees: lat, longitude: lon)
        let moonIllum = moon.illuminatedFraction
        let moonAlt   = moon.altitude(on: jd, for: obs)
        let sr = sun.riseTransitSet(on: jd, for: obs).rise?.date ?? date
        let ss = sun.riseTransitSet(on: jd, for: obs).set?.date ?? date
        return AstroData(moonIllumination: moonIllum, moonAltitude: moonAlt, sunSet: ss, sunRise: sr)
    }
}
