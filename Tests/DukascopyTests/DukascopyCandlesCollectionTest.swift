//
//  DukascopyCandlesCollectionTest.swift
//  DukascopyTests
//
//  Created by Vitali Kurlovich on 4/20/20.
//

@testable import Dukascopy
import XCTest

private let formatter = FormatterUtils.formatter

final class DukascopyCandlesCollectionTest: XCTestCase {
    func testCandlesCollection() throws {
        let date = formatter.date(from: "02-04-2019 11:00")!

        let candles_1: [DukascopyCandle] = [
            .init(time: 0, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 12 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 25 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
        ]

        var collection_1 = DukascopyCandlesCollection(type: .ask, date: date, candles: candles_1)

        XCTAssertEqual(collection_1.candles.last, .init(time: 25 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0))

        let candles_2: [DukascopyCandle] = [
            .init(time: 28 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 32 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 45 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
        ]

        let collection_2 = DukascopyCandlesCollection(type: .ask, date: date, candles: candles_2)

        XCTAssertEqual(collection_2.candles.last, .init(time: 45 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0))

        collection_1.append(collection_2)

        XCTAssertEqual(collection_1.candles.last, .init(time: 45 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0))
    }

    func testCandlesCollection_1() throws {
        let date_1 = formatter.date(from: "02-04-2019 11:00")!

        let candles_1: [DukascopyCandle] = [
            .init(time: 0, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 12 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 25 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
        ]

        var collection_1 = DukascopyCandlesCollection(type: .ask, date: date_1, candles: candles_1)

        let date_2 = formatter.date(from: "02-04-2019 12:00")!

        let candles_2: [DukascopyCandle] = [
            .init(time: 28 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 32 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 45 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
        ]

        let collection_2 = DukascopyCandlesCollection(type: .ask, date: date_2, candles: candles_2)

        collection_1.append(collection_2)

        let candles: [DukascopyCandle] = [
            .init(time: 0, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 12 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 25 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),

            .init(time: 60 * 60 * 1000 + 28 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 60 * 60 * 1000 + 32 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
            .init(time: 60 * 60 * 1000 + 45 * 60, price: .init(open: 12, close: 12, low: 12, high: 12), volume: 0),
        ]

        XCTAssertEqual(collection_1, DukascopyCandlesCollection(type: .ask, date: date_1, candles: candles))
    }

    static var allTests = [
        ("testCandlesCollection", testCandlesCollection),
        ("testCandlesCollection_1", testCandlesCollection_1),
    ]
}
