import XCTest
@testable import Zhizu

final class CostCalculatorTests: XCTestCase {

    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Asia/Shanghai")!
        return c
    }()

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = m; c.day = d
        return calendar.date(from: c)!
    }

    func testSameDayOwnedIsOneDay() {
        let day = date(2026, 1, 31)
        let owned = CostCalculator.daysOwned(purchaseDate: day, now: day, calendar: calendar)
        XCTAssertEqual(owned, 1)
    }

    func testDaysOwnedCountsPurchaseDay() {
        let start = date(2026, 1, 1)
        let now = date(2026, 1, 11) // 10 days later
        let owned = CostCalculator.daysOwned(purchaseDate: start, now: now, calendar: calendar)
        XCTAssertEqual(owned, 11) // inclusive of purchase day
    }

    func testRetiredAssetUsesRetireDate() {
        let start = date(2026, 1, 1)
        let retire = date(2026, 1, 11)
        let now = date(2026, 6, 1) // far in the future, should be ignored
        let owned = CostCalculator.daysOwned(
            purchaseDate: start, retireDate: retire, now: now, calendar: calendar
        )
        XCTAssertEqual(owned, 11)
    }

    func testDailyCostMath() {
        XCTAssertEqual(CostCalculator.dailyCost(price: 1000, days: 10), 100, accuracy: 0.0001)
        XCTAssertEqual(CostCalculator.dailyCost(price: 3599, days: 128), 28.1171875, accuracy: 0.0001)
    }

    func testDailyCostNeverDividesByZero() {
        XCTAssertEqual(CostCalculator.dailyCost(price: 500, days: 0), 500, accuracy: 0.0001)
    }

    func testTotalValueAndDailyCostAggregation() {
        XCTAssertEqual(CostCalculator.totalValue([100, 200, 300]), 600, accuracy: 0.0001)
        XCTAssertEqual(CostCalculator.totalDailyCost([1.5, 2.5, 6]), 10, accuracy: 0.0001)
    }

    func testTargetProgress() {
        // Target already reached.
        XCTAssertEqual(
            CostCalculator.targetProgress(currentDailyCost: 4, originalDailyCost: 100, target: 5),
            1, accuracy: 0.0001
        )
        // Halfway from original (100) down to target (0) at current 50 -> span 100, traveled 50.
        XCTAssertEqual(
            CostCalculator.targetProgress(currentDailyCost: 50, originalDailyCost: 100, target: 0),
            0, accuracy: 0.0001 // target 0 is invalid -> 0
        )
        // Valid span: original 100, target 20, current 60 -> traveled 40 / span 80 = 0.5
        XCTAssertEqual(
            CostCalculator.targetProgress(currentDailyCost: 60, originalDailyCost: 100, target: 20),
            0.5, accuracy: 0.0001
        )
    }

    func testDailyCostCurveDecreasesOverTime() {
        let start = date(2026, 1, 1)
        let end = date(2026, 4, 1)
        let curve = CostCalculator.dailyCostCurve(
            price: 9000, purchaseDate: start, endDate: end, sampleCount: 10, calendar: calendar
        )
        XCTAssertEqual(curve.count, 10)
        // Monotonically non-increasing.
        for i in 1..<curve.count {
            XCTAssertLessThanOrEqual(curve[i].dailyCost, curve[i - 1].dailyCost + 0.0001)
        }
        // First point is day 1 == full price.
        XCTAssertEqual(curve.first!.dailyCost, 9000, accuracy: 0.5)
    }
}
