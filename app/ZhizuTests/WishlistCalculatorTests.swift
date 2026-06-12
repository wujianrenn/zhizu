import XCTest
@testable import Zhizu

final class WishlistCalculatorTests: XCTestCase {

    func testTotalAmount() {
        XCTAssertEqual(WishlistCalculator.totalAmount([9999, 29999, 1899]), 41897, accuracy: 0.001)
    }

    func testTotalAmountEmpty() {
        XCTAssertEqual(WishlistCalculator.totalAmount([]), 0, accuracy: 0.001)
    }

    func testCount() {
        XCTAssertEqual(WishlistCalculator.count([1, 2, 3]), 3)
        XCTAssertEqual(WishlistCalculator.count([]), 0)
    }
}
