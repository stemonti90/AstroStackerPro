import Foundation
import CoreML
import Vision
import UIKit

/// Result of analysing an astronomical image via the SkyRecognizer.
public struct SkyRecognitionResult {
    /// Right ascension of the centre of the field in degrees.
    public let rightAscension: Double
    /// Declination of the centre of the field in degrees.
    public let declination: Double
    /// Detected stars with their names (optional) and pixel positions.
    public let stars: [(name: String?, position: CGPoint)]
    /// Detected deep‑sky objects (e.g. Messier numbers) with positions.
    public let objects: [(name: String, position: CGPoint)]
}

/// An AI module that performs plate solving and star/constellation recognition.
/// It uses a convolutional neural network to detect stars and then matches the
/// detected pattern against an embedded catalogue to infer the field coordinates.
final class SkyRecognizer {
    /// An optional Core ML model wrapped in Vision for accelerated inference.
    /// When present, this model is used to perform star segmentation on input
    /// images.  If the model cannot be loaded, the recognizer falls back to
    /// threshold‑based star detection.
    private let vnModel: VNCoreMLModel?

    init() {
        // Attempt to locate and load a compiled ML model named "StarSegmenter"
        // from the app bundle.  Developers should add the compiled model
        // (.mlmodelc) to the project resources.  If loading fails the
        // recognizer will function using simple thresholding.
        if let url = Bundle.main.url(forResource: "StarSegmenter", withExtension: "mlmodelc") {
            do {
                let coreModel = try MLModel(contentsOf: url)
                vnModel = try? VNCoreMLModel(for: coreModel)
            } catch {
                vnModel = nil
            }
        } else {
            vnModel = nil
        }
    }

    /// Performs star detection using the CNN model if available.  If no model
    /// is present the method falls back to the thresholding‑based detector
    /// defined in StarRegistration.  The model is expected to output either a
    /// pixel buffer or a multi‑array segmentation map where each element
    /// encodes the likelihood that the corresponding pixel belongs to a star.
    /// Pixels with probabilities above 0.5 are treated as star pixels.
    /// - Parameter ciImage: The input CIImage in device coordinates.
    /// - Returns: A list of detected star features with centroid positions and
    ///            relative brightness estimates.
    private func detectStarFeatures(in ciImage: CIImage) -> [StarRegistration.StarFeature] {
        // Fallback to the standard detector if no ML model is available.
        guard let vnModel = self.vnModel else {
            let reg = StarRegistration()
            return reg.detectStarFeatures(in: ciImage)
        }
        // Convert the CIImage to CGImage for Vision.  Use a software context
        // for determinism and avoid GPU dependencies.
        let context = CIContext(options: [CIContextOption.useSoftwareRenderer: true])
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            let reg = StarRegistration()
            return reg.detectStarFeatures(in: ciImage)
        }
        // Prepare a Vision request.  The completion handler will parse the
        // output and build star centroids from the segmentation map.
        var detected: [StarRegistration.StarFeature] = []
        let request = VNCoreMLRequest(model: vnModel) { request, error in
            guard error == nil else { return }
            for result in request.results ?? [] {
                if let pixelObs = result as? VNPixelBufferObservation {
                    let buffer = pixelObs.pixelBuffer
                    // Access pixel buffer data in CPU memory.
                    CVPixelBufferLockBaseAddress(buffer, .readOnly)
                    let width = CVPixelBufferGetWidth(buffer)
                    let height = CVPixelBufferGetHeight(buffer)
                    guard let base = CVPixelBufferGetBaseAddress(buffer) else {
                        CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
                        continue
                    }
                    let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
                    let channels = 1 // assume single channel output
                    var mask: [[Double]] = Array(repeating: Array(repeating: 0.0, count: width), count: height)
                    for y in 0..<height {
                        let rowPtr = base.advanced(by: y * bytesPerRow)
                        for x in 0..<width {
                            // Interpret pixel as 8‑bit grayscale
                            let val = Double(rowPtr.load(fromByteOffset: x * channels, as: UInt8.self)) / 255.0
                            mask[y][x] = val
                        }
                    }
                    CVPixelBufferUnlockBaseAddress(buffer, .readOnly)
                    detected.append(contentsOf: self.clusterMask(mask))
                } else if let multiObs = result as? VNCoreMLFeatureValueObservation,
                          let array = multiObs.featureValue.multiArrayValue {
                    // Assume the multi‑array is in (channel,height,width) or (height,width).  Identify dimensions.
                    let shape = array.shape.map { Int(truncating: $0) }
                    var height = 0
                    var width = 0
                    var channelOffset = 0
                    if shape.count == 2 {
                        height = shape[0]
                        width = shape[1]
                        channelOffset = 0
                    } else if shape.count == 3 {
                        // Determine which dimension is channel; assume channel is first dimension.
                        let c = shape[0]
                        height = shape[1]
                        width = shape[2]
                        channelOffset = 0
                        if c == 1 {
                            channelOffset = 0
                        }
                    }
                    // Flatten the multiarray into a 2D mask.  Convert each value to Double.
                    var mask: [[Double]] = Array(repeating: Array(repeating: 0.0, count: width), count: height)
                    for y in 0..<height {
                        for x in 0..<width {
                            let idx: [NSNumber]
                            if shape.count == 2 {
                                idx = [NSNumber(value: y), NSNumber(value: x)]
                            } else {
                                idx = [NSNumber(value: channelOffset), NSNumber(value: y), NSNumber(value: x)]
                            }
                            let val = array[idx].doubleValue
                            mask[y][x] = val
                        }
                    }
                    detected.append(contentsOf: self.clusterMask(mask))
                }
            }
        }
        // Perform the request synchronously.
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            // Fallback if inference fails.
            let reg = StarRegistration()
            return reg.detectStarFeatures(in: ciImage)
        }
        // Sort by brightness.
        detected.sort { $0.brightness > $1.brightness }
        return detected
    }

    /// Given a probability mask where each value represents the likelihood of a
    /// pixel being part of a star, group contiguous pixels above a threshold
    /// into clusters and compute centroid positions and brightness.  A simple
    /// flood‑fill algorithm similar to StarRegistration.detectStarFeatures is
    /// used.  Pixels with probabilities below 0.5 are ignored.
    /// - Parameter mask: 2D array of probabilities between 0 and 1.
    /// - Returns: An array of StarFeature objects.
    private func clusterMask(_ mask: [[Double]]) -> [StarRegistration.StarFeature] {
        let height = mask.count
        guard height > 0 else { return [] }
        let width = mask[0].count
        var visited = Array(repeating: Array(repeating: false, count: width), count: height)
        var features: [StarRegistration.StarFeature] = []
        let neighbours = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
        for y in 0..<height {
            for x in 0..<width {
                if visited[y][x] { continue }
                let p = mask[y][x]
                // threshold at 0.5
                if p < 0.5 { continue }
                // flood fill cluster
                var queue: [(Int, Int)] = [(x, y)]
                visited[y][x] = true
                var sumX: Double = 0
                var sumY: Double = 0
                var totalP: Double = 0
                while !queue.isEmpty {
                    let (cx, cy) = queue.removeLast()
                    let prob = mask[cy][cx]
                    sumX += Double(cx) * prob
                    sumY += Double(cy) * prob
                    totalP += prob
                    for (dx, dy) in neighbours {
                        let nx = cx + dx
                        let ny = cy + dy
                        if nx < 0 || ny < 0 || nx >= width || ny >= height { continue }
                        if visited[ny][nx] { continue }
                        if mask[ny][nx] >= 0.5 {
                            visited[ny][nx] = true
                            queue.append((nx, ny))
                        }
                    }
                }
                if totalP > 0 {
                    let cx = sumX / totalP
                    let cy = sumY / totalP
                    let pos = CGPoint(x: CGFloat(cx), y: CGFloat(cy))
                    let feature = StarRegistration.StarFeature(position: pos, brightness: totalP)
                    features.append(feature)
                }
            }
        }
        return features
    }

    /// Runs the AI analysis on the provided image.  The algorithm detects
    /// bright star centroids in the image, matches them against a small
    /// catalogue of bright stars using scale/rotation invariant triples and
    /// computes an approximate affine transform from image coordinates to
    /// equatorial coordinates.  The centre of the field is then inferred
    /// from this transform.  The method returns the matched stars and an
    /// empty list of deep‑sky objects (to be populated in a more complete
    /// implementation).
    /// - Parameter uiImage: The UIImage to analyse.
    /// - Returns: A result containing estimated RA/Dec of the field centre and
    ///            annotations for matched stars.  Returns nil if the image cannot
    ///            be analysed.
    func recognise(_ uiImage: UIImage) -> SkyRecognitionResult? {
        guard let ciImage = CIImage(image: uiImage) else { return nil }
        // Detect star features using the CNN model if available, falling back
        // to StarRegistration's threshold detector.
        let features = detectStarFeatures(in: ciImage)
        // Need at least three detected stars to perform matching.
        guard features.count >= 3 else { return nil }
        // Limit to the brightest few detections to reduce combinatorial growth.
        let maxStarsToUse = 5
        let usedFeatures = Array(features.prefix(min(maxStarsToUse, features.count)))

        // Precompute detection triple signatures.
        struct DetTriple { let indices: (Int, Int, Int); let signature: (Double, Double) }
        var detTriples: [DetTriple] = []
        let m = usedFeatures.count
        if m >= 3 {
            for i in 0..<(m - 2) {
                for j in (i + 1)..<(m - 1) {
                    for k in (j + 1)..<m {
                        let pts = [usedFeatures[i].position, usedFeatures[j].position, usedFeatures[k].position]
                        let sig = SkyRecognizer.normalisedSignature(forPoints: pts)
                        detTriples.append(DetTriple(indices: (i, j, k), signature: sig))
                    }
                }
            }
        }
        guard !detTriples.isEmpty else { return nil }

        // Precompute catalogue triples.
        let catalogTriples = StarCatalog.shared.tripleSignatures()
        guard !catalogTriples.isEmpty else { return nil }

        // Find the best matching triple between detections and catalogue using
        // sum of squared differences of the signature.
        var bestMatch: (detTriple: DetTriple, catTriple: (stars: (Star, Star, Star), signature: (Double, Double)), score: Double)? = nil
        for det in detTriples {
            for cat in catalogTriples {
                let dx = det.signature.0 - cat.signature.0
                let dy = det.signature.1 - cat.signature.1
                let score = dx * dx + dy * dy
                if bestMatch == nil || score < (bestMatch!.score) {
                    bestMatch = (det, cat, score)
                }
            }
        }
        guard let match = bestMatch else { return nil }

        // Extract the matched points and star coordinates.  Use only the three
        // matched detections to compute the affine transform.
        let detIndices = [match.detTriple.indices.0, match.detTriple.indices.1, match.detTriple.indices.2]
        var detPoints: [CGPoint] = []
        for idx in detIndices { detPoints.append(usedFeatures[idx].position) }
        let catStars = [match.catTriple.stars.0, match.catTriple.stars.1, match.catTriple.stars.2]
        // Project the catalogue star positions onto a plane for transform
        var catPoints: [CGPoint] = []
        for star in catStars {
            let radDec = star.declination * Double.pi / 180.0
            let x = star.rightAscension * cos(radDec)
            let y = star.declination
            catPoints.append(CGPoint(x: x, y: y))
        }

        // Compute affine transform from detection pixel coordinates to RA/Dec plane.
        guard let affine = SkyRecognizer.affineTransform(from: detPoints, to: catPoints) else { return nil }

        // Estimate the RA/Dec of the field centre by mapping the image centre.
        let imgSize = uiImage.size
        let centrePixel = CGPoint(x: imgSize.width / 2.0, y: imgSize.height / 2.0)
        let mapped = centrePixel.applying(affine)
        // Convert back to RA and Dec: dec = y; ra = x / cos(dec)
        let dec = Double(mapped.y)
        let ra = Double(mapped.x) / cos(dec * Double.pi / 180.0)

        // Build list of matched stars for annotation.  Only include the three
        // matched catalogue stars; additional stars could be matched by nearest
        // neighbour search in a more complete implementation.
        var annotatedStars: [(name: String?, position: CGPoint)] = []
        for (detPoint, star) in zip(detPoints, catStars) {
            annotatedStars.append((name: star.name, position: detPoint))
        }

        // Identify deep‑sky objects in the field.  For each object in the
        // catalogue compute its angular separation from the field centre.  If
        // within a threshold (e.g. 3°) include it as an annotation.  Compute
        // the pixel position by projecting the object's RA/Dec through the
        // inverse of the affine transform.  The separation formula uses a
        // small‑angle approximation: Δθ ≈ sqrt((ΔRA·cos(dec))² + (ΔDec)²).
        var deepObjects: [(name: String, position: CGPoint)] = []
        let inverse = affine.inverted()
        for obj in DeepSkyCatalog.shared.objects {
            // Angular separation from field centre.
            let deltaDec = obj.declination - dec
            let cosDec = cos(dec * Double.pi / 180.0)
            let deltaRA = (obj.rightAscension - ra) * cosDec
            let separation = sqrt(deltaRA * deltaRA + deltaDec * deltaDec)
            // Only annotate objects within ~3 degrees of the centre.
            if separation < 3.0 {
                // Project RA/Dec to RA/Dec plane coordinates used in the affine transform.
                let radDecObj = obj.declination * Double.pi / 180.0
                let x = obj.rightAscension * cos(radDecObj)
                let y = obj.declination
                let pt = CGPoint(x: x, y: y)
                let pixelPos = pt.applying(inverse)
                deepObjects.append((name: obj.name, position: pixelPos))
            }
        }

        return SkyRecognitionResult(rightAscension: ra, declination: dec, stars: annotatedStars, objects: deepObjects)
    }

    /// Computes an affine transform that maps three source points to three
    /// destination points.  Returns nil if the points are degenerate.  The
    /// transform has the form: dest = A * src + t.  The algorithm solves a
    /// linear system using least squares.
    private static func affineTransform(from src: [CGPoint], to dst: [CGPoint]) -> CGAffineTransform? {
        guard src.count == 3 && dst.count == 3 else { return nil }
        // Build matrices for the linear system.  We have:
        // [ x1 y1 1 0  0  0 ] [a] = [X1]
        // [ 0  0  0 x1 y1 1 ] [b]   [Y1]
        // [ x2 y2 1 0  0  0 ] [c]   [X2]
        // [ 0  0  0 x2 y2 1 ] [d]   [Y2]
        // [ x3 y3 1 0  0  0 ] [e]   [X3]
        // [ 0  0  0 x3 y3 1 ] [f]   [Y3]
        // Where (a,c,e) are the first row of the affine matrix and (b,d,f) the second row.
        var A = [[Double]](repeating: [Double](repeating: 0.0, count: 6), count: 6)
        var B = [Double](repeating: 0.0, count: 6)
        for i in 0..<3 {
            let sx = Double(src[i].x)
            let sy = Double(src[i].y)
            let dx = Double(dst[i].x)
            let dy = Double(dst[i].y)
            // X equation
            let rowX = i * 2
            A[rowX][0] = sx
            A[rowX][1] = sy
            A[rowX][2] = 1.0
            A[rowX][3] = 0.0
            A[rowX][4] = 0.0
            A[rowX][5] = 0.0
            B[rowX] = dx
            // Y equation
            let rowY = rowX + 1
            A[rowY][0] = 0.0
            A[rowY][1] = 0.0
            A[rowY][2] = 0.0
            A[rowY][3] = sx
            A[rowY][4] = sy
            A[rowY][5] = 1.0
            B[rowY] = dy
        }
        // Solve the linear system using Gaussian elimination.
        var mat = A
        var rhs = B
        // Forward elimination
        for i in 0..<6 {
            // Find pivot
            var maxRow = i
            var maxVal = abs(mat[i][i])
            for r in (i + 1)..<6 {
                let v = abs(mat[r][i])
                if v > maxVal {
                    maxVal = v
                    maxRow = r
                }
            }
            if maxVal < 1e-8 { return nil }
            if maxRow != i {
                mat.swapAt(i, maxRow)
                rhs.swapAt(i, maxRow)
            }
            // Normalize pivot row
            let pivot = mat[i][i]
            for c in i..<6 { mat[i][c] /= pivot }
            rhs[i] /= pivot
            // Eliminate other rows
            for r in 0..<6 {
                if r == i { continue }
                let factor = mat[r][i]
                if abs(factor) > 0 {
                    for c in i..<6 {
                        mat[r][c] -= factor * mat[i][c]
                    }
                    rhs[r] -= factor * rhs[i]
                }
            }
        }
        // Solution vector
        let a = rhs[0]
        let c = rhs[1]
        let e = rhs[2]
        let b = rhs[3]
        let d = rhs[4]
        let f = rhs[5]
        return CGAffineTransform(a: CGFloat(a), b: CGFloat(b), c: CGFloat(c), d: CGFloat(d), tx: CGFloat(e), ty: CGFloat(f))
    }

    /// Computes the normalised signature for three detected points.  See
    /// StarCatalog.normalisedSignature(for:) for the catalogue version.  Points
    /// are in pixel space.  Distances are divided by the longest edge to
    /// normalise scale and sorted.  Rotation does not affect the signature.
    private static func normalisedSignature(forPoints pts: [CGPoint]) -> (Double, Double) {
        func dist2(_ a: CGPoint, _ b: CGPoint) -> Double {
            let dx = Double(a.x - b.x)
            let dy = Double(a.y - b.y)
            return dx * dx + dy * dy
        }
        let d12 = dist2(pts[0], pts[1])
        let d13 = dist2(pts[0], pts[2])
        let d23 = dist2(pts[1], pts[2])
        let distances = [d12, d13, d23].sorted()
        let largest = distances[2]
        guard largest > 0 else { return (0, 0) }
        let n1 = distances[0] / largest
        let n2 = distances[1] / largest
        return (n1, n2)
    }

    /// Provides a local database lookup for astronomical objects near the solved field.
    /// In a real implementation this would query a SQLite database bundled with the app.
    private func queryCatalog(ra: Double, dec: Double, fov: Double) -> [(name: String, position: CGPoint)] {
        // Placeholder implementation returns no objects.  A future version of
        // AstroStackerPro could bundle a catalogue of Messier objects and use the
        // affine transform computed above to convert their RA/Dec to pixel
        // coordinates for overlay.
        return []
    }
}