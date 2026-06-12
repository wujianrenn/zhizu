import XCTest
@testable import Zhizu

private struct StubAsset: AssetSortable {
    var sortPrice: Double
    var sortDailyCost: Double
    var sortPurchaseDate: Date
    var sortDaysOwned: Int
}

final class SortOptionTests: XCTestCase {

    private func date(_ offsetDays: Int) -> Date {
        Date(timeIntervalSince1970: 1_700_000_000).addingTimeInterval(Double(offsetDays) * 86_400)
    }

    private lazy var items: [StubAsset] = [
        StubAsset(sortPrice: 100, sortDailyCost: 5, sortPurchaseDate: date(0), sortDaysOwned: 20),
        StubAsset(sortPrice: 300, sortDailyCost: 1, sortPurchaseDate: date(10), sortDaysOwned: 300),
        StubAsset(sortPrice: 200, sortDailyCost: 9, sortPurchaseDate: date(5), sortDaysOwned: 10)
    ]

    func testSortByPriceDescending() {
        let sorted = SortOption(field: .price, direction: .descending).sorted(items)
        XCTAssertEqual(sorted.map(\.sortPrice), [300, 200, 100])
    }

    func testSortByPriceAscending() {
        let sorted = SortOption(field: .price, direction: .ascending).sorted(items)
        XCTAssertEqual(sorted.map(\.sortPrice), [100, 200, 300])
    }

    func testSortByDailyCostDescending() {
        let sorted = SortOption(field: .dailyCost, direction: .descending).sorted(items)
        XCTAssertEqual(sorted.map(\.sortDailyCost), [9, 5, 1])
    }

    func testSortByDaysOwnedAscending() {
        let sorted = SortOption(field: .daysOwned, direction: .ascending).sorted(items)
        XCTAssertEqual(sorted.map(\.sortDaysOwned), [10, 20, 300])
    }

    func testSortByPurchaseDateDescending() {
        let sorted = SortOption(field: .purchaseDate, direction: .descending).sorted(items)
        XCTAssertEqual(sorted.map(\.sortPurchaseDate), [date(10), date(5), date(0)])
    }
}
