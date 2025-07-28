import XCTest
@testable import AstroStackerPro

final class ProcessingTests: XCTestCase {
    func testProcessNoFramesReturnsNil() {
        let manager = AstroCaptureManager()
        XCTAssertNil(manager.processFrames(applyLightPollution: false))
    }
}
