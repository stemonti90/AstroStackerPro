import Foundation

/// Represents a bright star with a name and equatorial coordinates (RA/Dec).
/// RA and dec are stored in decimal degrees.  RA has been multiplied by 15 to
/// convert hours to degrees.  These values are based on the J2000 epoch.  The
/// catalogue can be extended with additional stars or loaded from a file as
/// needed.
public struct Star {
    public let name: String
    public let rightAscension: Double
    public let declination: Double
}

/// A simple in‑memory catalogue of bright stars.  The static shared instance
/// holds a handful of notable stars along with their equatorial coordinates.
/// The coordinates in this list were computed from hour/minute/second
/// measurements described in reputable astronomy sources such as AstroPixels
/// and EarthSky articles【8127431255770†L7-L10】【64641986650312†L14-L16】【920047610593690†L15-L17】【837906627316511†L273-L274】【409221869552651†L220-L225】.
public final class StarCatalog {
    /// Shared singleton instance.
    public static let shared = StarCatalog()
    /// The list of bright stars.
    public let stars: [Star]

    private init() {
        // Hardcode a small catalogue of bright stars.  Additional stars can be
        // added here.  Coordinates are in decimal degrees.
        // The following coordinates are given in decimal degrees (RA hours × 15).
        // Existing entries such as Polaris, Betelgeuse, Vega, Deneb and Rigel
        // come from the original implementation.  We expand the catalogue
        // below with additional bright stars.  Coordinates are computed
        // directly from hour/minute/second values gathered from astronomy
        // sources like AstroPixels, UniverseGuide and EarthSky
        // 【298226404896485†L143-L149】【986268398459242†L14-L15】【214855276910750†L679-L685】【468517946049224†L93-L94】【511384322624663†L249-L251】.
        stars = [
            // Original sample stars
            Star(name: "Polaris", rightAscension: 37.960417, declination: 89.264167),
            Star(name: "Betelgeuse", rightAscension: 88.792917, declination: 7.406944),
            Star(name: "Vega", rightAscension: 279.234583, declination: 38.783611),
            Star(name: "Deneb", rightAscension: 310.358333, declination: 45.280278),
            Star(name: "Rigel", rightAscension: 78.634583, declination: -8.201639),
            // Additional bright stars (coordinates converted to decimal degrees)
            // Sirius: RA 6h 45m 8.9s, Dec −16° 42′ 58″【298226404896485†L143-L149】【986268398459242†L14-L15】
            Star(name: "Sirius", rightAscension: 101.287083, declination: -16.716111),
            // Altair: RA 19h 50m 46.68s, Dec +08° 52′ 02.6″【214855276910750†L679-L685】
            Star(name: "Altair", rightAscension: 297.694500, declination: 8.867389),
            // Capella: RA 05h 16m 41s, Dec +45° 59′ 53″【468517946049224†L93-L94】
            Star(name: "Capella", rightAscension: 79.170833, declination: 45.998056),
            // Arcturus: RA 14h 15m 39.7s, Dec +19° 10′ 56″【511384322624663†L249-L251】
            Star(name: "Arcturus", rightAscension: 213.915417, declination: 19.182222)
        ]
    }

    /// Returns the current equatorial coordinates (RA/Dec) for a given star.
    /// This method is a placeholder for applying precession corrections to
    /// epoch‑2000 coordinates.  Currently it returns the catalogue values
    /// unchanged.  In future versions this should implement proper precession
    /// to transform J2000 coordinates to the observation epoch.
    /// - Parameters:
    ///   - star: The star whose coordinates to compute.
    ///   - epoch: Target epoch (e.g. 2025.0).  Ignored in this placeholder.
    /// - Returns: Tuple of right ascension and declination in degrees.
    public func currentCoordinates(for star: Star, epoch: Double = 2025.0) -> (ra: Double, dec: Double) {
        // TODO: implement precession from J2000 to the specified epoch.
        return (star.rightAscension, star.declination)
    }
}

extension StarCatalog {
    /// Returns all unique combinations of three stars from the catalogue along
    /// with their normalised distance signatures.  A signature consists of the
    /// two shorter side lengths divided by the longest side and sorted.  These
    /// signatures are used to match triples of detected stars to catalog triples
    /// independent of scale and rotation.
    func tripleSignatures() -> [(stars: (Star, Star, Star), signature: (Double, Double))] {
        var results: [(stars: (Star, Star, Star), signature: (Double, Double))] = []
        let n = stars.count
        if n < 3 { return results }
        for i in 0..<(n - 2) {
            for j in (i + 1)..<(n - 1) {
                for k in (j + 1)..<n {
                    let a = stars[i]
                    let b = stars[j]
                    let c = stars[k]
                    let sig = StarCatalog.normalisedSignature(for: [a, b, c])
                    results.append(((a, b, c), sig))
                }
            }
        }
        return results
    }

    /// Computes the normalised signature for three stars.  Positions are
    /// projected onto a plane using x = ra * cos(dec), y = dec so that RA and
    /// dec differences can be treated in Euclidean space for small fields of
    /// view.
    private static func normalisedSignature(for triple: [Star]) -> (Double, Double) {
        // Project stars onto a plane.
        let projected = triple.map { star -> (Double, Double) in
            let radDec = star.declination * Double.pi / 180.0
            let x = star.rightAscension * cos(radDec)
            let y = star.declination
            return (x, y)
        }
        // Compute pairwise distances squared.
        func dist2(_ a: (Double, Double), _ b: (Double, Double)) -> Double {
            let dx = a.0 - b.0
            let dy = a.1 - b.1
            return dx * dx + dy * dy
        }
        let d12 = dist2(projected[0], projected[1])
        let d13 = dist2(projected[0], projected[2])
        let d23 = dist2(projected[1], projected[2])
        let distances = [d12, d13, d23].sorted()
        // Normalise by the largest distance to be invariant under scale.
        let largest = distances[2]
        guard largest > 0 else { return (0, 0) }
        let n1 = distances[0] / largest
        let n2 = distances[1] / largest
        return (n1, n2)
    }
}