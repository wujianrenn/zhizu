import XCTest
@testable import Zhizu

final class FormattersTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Formatters.currencySymbol = "¥"
    }

    func testPriceTwoDecimals() {
        XCTAssertEqual(Formatters.price(3599), "¥3599.00")
        XCTAssertEqual(Formatters.price(98.5), "¥98.50")
    }

    func testPriceGroupedSeparators() {
        XCTAssertEqual(Formatters.priceGrouped(21593), "¥21,593.00")
    }

    func testPriceCompactDropsTrailingZeros() {
        XCTAssertEqual(Formatters.priceCompact(3599), "¥3599")
    }

    func testDailyCostFormats() {
        XCTAssertEqual(Formatters.dailyCost(28.117), "¥28.12")
        XCTAssertEqual(Formatters.dailyCostPerDay(28.117, locale: Locale(identifier: "zh-Hans")), "¥28.12/天")
    }

    func testDailyCostDetailedKeepsPrecision() {
        XCTAssertEqual(Formatters.dailyCostDetailed(28.1171875), "¥28.117")
    }

    func testPercentClampsAndRounds() {
        XCTAssertEqual(Formatters.percent(0.726), "73%")
        XCTAssertEqual(Formatters.percent(1.4), "100%")
        XCTAssertEqual(Formatters.percent(-0.2), "0%")
    }

    func testDaysFormat() {
        XCTAssertEqual(Formatters.days(128, locale: Locale(identifier: "zh-Hans")), "128 天")
    }

    func testCurrencySymbolIsConfigurable() {
        Formatters.currencySymbol = "$"
        XCTAssertEqual(Formatters.price(10), "$10.00")
        Formatters.currencySymbol = "¥"
    }
}
