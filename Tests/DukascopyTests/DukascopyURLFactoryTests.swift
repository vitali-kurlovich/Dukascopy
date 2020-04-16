//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 4/4/20.
//

@testable import Dukascopy
import XCTest

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.timeZone = utc
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
}()

final class DukascopyURLFactoryTests: XCTestCase {
    func testURLFactory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let factory = DukascopyURLFactory()

        let date = formatter.date(from: "02-04-2019 11:00")!
        let url = try! factory.url(for: "EURUSD", date: date)

        XCTAssertEqual(url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/02/11h_ticks.bi5"))

        let end = formatter.date(from: "02-04-2019 14:00")!

        let urls = try! factory.url(for: "EURUSD", range: date ..< end)

        XCTAssertEqual(urls.count, 3)
        XCTAssertEqual(urls[0].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/02/11h_ticks.bi5"))
        XCTAssertEqual(urls[1].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/02/12h_ticks.bi5"))
        XCTAssertEqual(urls[2].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/02/13h_ticks.bi5"))
    }

    func testURLFactoryErrors() {
        let factory = DukascopyURLFactory()
        typealias FactoryError = DukascopyURLFactory.FactoryError

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 13, day: 1, hour: 1)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidMonth)
        }

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 0, day: 1, hour: 1)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidMonth)
        }

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 10, day: 0, hour: 1)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidDay)
        }

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 10, day: 32, hour: 1)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidDay)
        }

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 10, day: 5, hour: -1)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidHour)
        }

        XCTAssertThrowsError(try factory.url(for: "EURUSD", year: 2000, month: 10, day: 5, hour: 24)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidHour)
        }

        XCTAssertThrowsError(try factory.url(for: "", year: 2000, month: 10, day: 5, hour: 12)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidCurrency)
        }

        let begin = formatter.date(from: "02-04-2019 11:00")!
        let end = formatter.date(from: "02-04-2019 14:00")!

        let range = begin ..< end

        XCTAssertThrowsError(try factory.url(for: "", range: range)) { error in
            XCTAssertEqual(error as! DukascopyURLFactory.FactoryError, FactoryError.invalidCurrency)
        }
    }

    static var allTests = [
        ("testURLFactory", testURLFactory),
        ("testURLFactoryErrors", testURLFactoryErrors),
    ]
}
