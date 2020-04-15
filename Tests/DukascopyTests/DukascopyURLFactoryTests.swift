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
    formatter.dateFormat = "MM-dd-yyyy HH:mm"
    return formatter
}()

final class DukascopyURLFactoryTests: XCTestCase {
    func testURLFactory() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        let factory = DukascopyURLFactory()

        let date = formatter.date(from: "04-04-2019 11:00")!
        let url = try! factory.url(for: "EURUSD", date: date)

        XCTAssertEqual(url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/04/11h_ticks.bi5"))

        let end = formatter.date(from: "04-04-2019 14:00")!

        let urls = try! factory.url(for: "EURUSD", range: date ..< end)

        XCTAssertEqual(urls.count, 3)
        XCTAssertEqual(urls[0].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/04/11h_ticks.bi5"))
        XCTAssertEqual(urls[1].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/04/12h_ticks.bi5"))
        XCTAssertEqual(urls[2].url, URL(string: "https://www.dukascopy.com/datafeed/EURUSD/2019/03/04/13h_ticks.bi5"))
    }

    static var allTests = [
        ("testURLFactory", testURLFactory),
    ]
}
