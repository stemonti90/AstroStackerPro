import XCTest
@testable import AstroStackerPro

final class FeatureFlagServiceTests: XCTestCase {
    func testDefaultValues() {
        let service = FeatureFlagService.shared
        XCTAssertEqual(service.variant("paywall_layout"), "A")
        XCTAssertEqual(service.getFloat("denoise_strength_default"), 0.5, accuracy: 0.001)
    }
}
