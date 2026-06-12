import XCTest
@testable import Zhizu

final class StatsCalculatorTests: XCTestCase {

    private var calendar = Calendar(identifier: .gregorian)
    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        var c = DateComponents(); c.year = y; c.month = m; c.day = d
        return calendar.date(from: c)!
    }

    private func snapshots() -> [AssetSnapshot] {
        [
            AssetSnapshot(category: "手机", purchaseDate: date(2025, 1, 1), purchasePrice: 5999,
                          isInUse: true, retireDate: nil, salePrice: nil, dailyCost: 10),
            AssetSnapshot(category: "电脑", purchaseDate: date(2024, 6, 1), purchasePrice: 5500,
                          isInUse: true, retireDate: nil, salePrice: nil, dailyCost: 8),
            AssetSnapshot(category: "手机", purchaseDate: date(2023, 9, 1), purchasePrice: 1200,
                          isInUse: false, retireDate: date(2025, 10, 1), salePrice: 800, dailyCost: 2)
        ]
    }

    func testTotalValueOnlyInUse() {
        XCTAssertEqual(StatsCalculator.totalValue(snapshots()), 11499, accuracy: 0.001)
    }

    func testTotalDailyCostOnlyInUse() {
        XCTAssertEqual(StatsCalculator.totalDailyCost(snapshots()), 18, accuracy: 0.001)
    }

    func testCategoryDistributionSortedDesc() {
        let dist = StatsCalculator.categoryDistribution(snapshots())
        XCTAssertEqual(dist.count, 2)
        XCTAssertEqual(dist.first?.category, "手机")
        XCTAssertEqual(dist.first?.amount, 5999, accuracy: 0.001)
        XCTAssertEqual(dist.last?.category, "电脑")
    }

    func testPurchaseSaleSummaryAllTime() {
        let s = StatsCalculator.purchaseSaleSummary(snapshots(), start: nil, now: date(2026, 1, 1))
        XCTAssertEqual(s.purchaseAmount, 12699, accuracy: 0.001)
        XCTAssertEqual(s.purchaseCount, 3)
        XCTAssertEqual(s.saleAmount, 800, accuracy: 0.001)
        XCTAssertEqual(s.saleCount, 1)
    }

    func testPurchaseSaleSummaryWindowed() {
        // Only purchases on/after 2024-01-01 count.
        let s = StatsCalculator.purchaseSaleSummary(
            snapshots(), start: date(2024, 1, 1), now: date(2026, 1, 1)
        )
        XCTAssertEqual(s.purchaseCount, 2) // 2025 phone + 2024 mac
        XCTAssertEqual(s.purchaseAmount, 11499, accuracy: 0.001)
        XCTAssertEqual(s.saleCount, 1) // retired 2025-10 with explicit sale price
        XCTAssertEqual(s.saleAmount, 800, accuracy: 0.001)
    }

    func testSaleSummaryIgnoresRetiredWithoutSalePrice() {
        let assets = [
            AssetSnapshot(category: "手机", purchaseDate: date(2023, 9, 1), purchasePrice: 1200,
                          isInUse: false, retireDate: date(2025, 10, 1), salePrice: nil, dailyCost: 2)
        ]
        let s = StatsCalculator.purchaseSaleSummary(assets, start: nil, now: date(2026, 1, 1))
        XCTAssertEqual(s.saleAmount, 0, accuracy: 0.001)
        XCTAssertEqual(s.saleCount, 0)
    }

    func testCumulativeValueTrendIsIncreasing() {
        let trend = StatsCalculator.cumulativeValueTrend(snapshots())
        XCTAssertEqual(trend.count, 3)
        XCTAssertEqual(trend.first?.value, 1200, accuracy: 0.001) // earliest 2023
        XCTAssertEqual(trend.last?.value, 12699, accuracy: 0.001)
        for i in 1..<trend.count {
            XCTAssertGreaterThanOrEqual(trend[i].value, trend[i - 1].value)
        }
    }
}
