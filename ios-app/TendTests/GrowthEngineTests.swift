import XCTest
@testable import Tend

final class GrowthEngineTests: XCTestCase {
    func testZeroLoggedIsSeed() {
        let stage = GrowthEngine.stage(loggedML: 0, goalML: 2000)
        XCTAssertEqual(stage, .seed)
    }

    func testTenPercentIsSprout() {
        let stage = GrowthEngine.stage(loggedML: 200, goalML: 2000) // 10%
        XCTAssertEqual(stage, .sprout)
    }

    func testExactQuarterIsStem() {
        // 500/2000 = 25% -> boundary, stem band starts at 25
        let stage = GrowthEngine.stage(loggedML: 500, goalML: 2000)
        XCTAssertEqual(stage, .stem)
    }

    func testHalfIsBud() {
        let stage = GrowthEngine.stage(loggedML: 1000, goalML: 2000) // 50%
        XCTAssertEqual(stage, .bud)
    }

    func testSeventyFivePercentIsOpeningBloom() {
        let stage = GrowthEngine.stage(loggedML: 1500, goalML: 2000) // 75%
        XCTAssertEqual(stage, .openingBloom)
    }

    func testExactGoalIsFullBloom() {
        let stage = GrowthEngine.stage(loggedML: 2000, goalML: 2000) // 100%
        XCTAssertEqual(stage, .fullBloom)
    }

    func testOverGoalIsStillFullBloomNotBeyond() {
        let stage = GrowthEngine.stage(loggedML: 5000, goalML: 2000) // 250%
        XCTAssertEqual(stage, .fullBloom)
    }

    func testDayQualifiesOnlyAtFullBloom() {
        XCTAssertFalse(GrowthEngine.dayQualifies(loggedML: 1999, goalML: 2000))
        XCTAssertTrue(GrowthEngine.dayQualifies(loggedML: 2000, goalML: 2000))
    }

    func testZeroGoalDoesNotCrashAndYieldsSeed() {
        let stage = GrowthEngine.stage(loggedML: 500, goalML: 0)
        XCTAssertEqual(stage, .seed)
    }

    func testDeterministicForSameInput() {
        let a = GrowthEngine.stage(loggedML: 1234, goalML: 2000)
        let b = GrowthEngine.stage(loggedML: 1234, goalML: 2000)
        XCTAssertEqual(a, b)
    }
}
