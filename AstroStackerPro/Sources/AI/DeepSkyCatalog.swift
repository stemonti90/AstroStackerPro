import Foundation

/// Represents a deep‑sky object (galaxy, nebula, cluster) with a name and
/// approximate equatorial coordinates.  RA is in decimal degrees (hours × 15)
/// and dec in decimal degrees.  Coordinates here are approximate J2000 values
/// for some prominent Messier objects; the catalogue can be extended as
/// required.
public struct DeepSkyObject {
    public let name: String
    public let rightAscension: Double
    public let declination: Double
}

/// A simple in‑memory catalogue of deep‑sky objects.  For demonstration
/// purposes only a handful of Messier objects are included.  These values
/// are approximate and should be refined or replaced with data from
/// authoritative catalogues if precise plate solving is required.
public final class DeepSkyCatalog {
    public static let shared = DeepSkyCatalog()
    public let objects: [DeepSkyObject]

    private init() {
        // Populate with a few well‑known objects.  Right ascension (RA) and
        // declination (dec) values are given in degrees.  For example, M31
        // (Andromeda Galaxy) has RA ≈ 0h 42m 44.3s (10.6847°) and Dec ≈ +41° 16′ 9″ (41.269°).
        objects = [
            DeepSkyObject(name: "M31", rightAscension: 10.6847, declination: 41.2690),  // Andromeda Galaxy
            DeepSkyObject(name: "M42", rightAscension: 83.6331, declination: -5.3911),   // Orion Nebula
            DeepSkyObject(name: "M13", rightAscension: 250.4217, declination: 36.4611),  // Hercules Globular Cluster
            DeepSkyObject(name: "M45", rightAscension: 56.75, declination: 24.1167)     // Pleiades
        ]
    }
}