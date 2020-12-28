//
//  DukascopyProviderTests.swift
//  DukascopyTests
//
//  Created by Vitali Kurlovich on 4/16/20.
//

@testable import Dukascopy
import DukascopyModel
import XCTest

@available(OSX 10.11, *)
class DukascopyProviderTests: XCTestCase {
    func testDownload() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let provider = DukascopyTicksProvider()

        let date = formatter.date(from: "01-01-2020 22:00")!

        try? provider.fetch(for: "EURUSD", date: date, completion: { result in

            switch result {
            case let .success(container):
                let ticks = container.ticks

                XCTAssertEqual(ticks.count, 1423)

                XCTAssertEqual(ticks[0].askp, 112_160)

                /*
                XCTAssertEqualDate(ticks[0].date, accuracyFormatter.date(from: "01-01-2020 22:01:12.821")!)

                XCTAssertEqual(ticks[0].price.ask, 112_160)

                XCTAssertEqualDate(ticks[0].date, accuracyFormatter.date(from: "01-01-2020 22:01:12.821")!)

                XCTAssertEqual(ticks[5].price.ask, 112_161)
                XCTAssertEqual(ticks[5].price.bid, 112_122)

                XCTAssertEqual(ticks[5].volume.ask, 0.0937, accuracy: 0.001)
                XCTAssertEqual(ticks[5].volume.bid, 0.75, accuracy: 0.001)

                XCTAssertEqualDate(ticks[5].date, accuracyFormatter.date(from: "01-01-2020 22:01:21.124")!)

                let last = ticks.last!

                // 01.01.2020 22:59:50.894,1.1215700000000002,1.12143,0.19,0.75

                XCTAssertEqual(last.price, Price(ask: 112_157, bid: 112_143))

                XCTAssertEqual(last.volume.ask, 0.19, accuracy: 0.001)
                XCTAssertEqual(last.volume.bid, 0.75, accuracy: 0.001)

                XCTAssertEqualDate(last.date, accuracyFormatter.date(from: "01-01-2020 22:59:50.894")!)
                */

            case .failure:
                XCTFail("wrong error")
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownload_1() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let provider = DukascopyTicksProvider()

        let begin = formatter.date(from: "01-01-2020 22:00")!
        let end = formatter.date(from: "02-01-2020 00:00")!

        let range = begin ..< end

        try? provider.fetch(for: "EURUSD", range: range, completion: { result in

            switch result {
            case let .success(container):
                let ticks = container.ticks
                XCTAssertEqual(ticks.count, 2786)

                // 01.01.2020 22:01:12.821,1.1216000000000002,1.1210600000000002,0.0937,0.75

                guard let first = ticks.first else {
                    XCTFail("ticks.first == nil")
                    return
                }
            /*
             XCTAssertEqual(first.price, Price(ask: 112_160, bid: 112_106))
             
             XCTAssertEqual(first.volume.ask, 0.0937, accuracy: 0.001)
             XCTAssertEqual(first.volume.bid, 0.75, accuracy: 0.001)
             
             XCTAssertEqualDate(first.date, accuracyFormatter.date(from: "01-01-2020 22:01:12.821")!)
             
             // 01.01.2020 23:59:54.234,1.1219100000000002,1.12188,0.19,0.19
             
             let last = ticks.last!
             
             XCTAssertEqual(last.price, Price(ask: 112_191, bid: 112_188))
             
             XCTAssertEqual(last.volume.ask, 0.19, accuracy: 0.001)
             XCTAssertEqual(last.volume.bid, 0.19, accuracy: 0.001)
             
             XCTAssertEqualDate(last.date, accuracyFormatter.date(from: "01-01-2020 23:59:54.234")!)
             */
            case .failure:
                XCTFail("wrong error")
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }

    func testDownloadCandles() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let provider = CandlesProvider()

        let date = formatter.date(from: "01-01-2020 22:00")!

        try? provider.fetch(for: "EURUSD", date: date, completion: { result in

            switch result {
            case let .success(candles):

                XCTAssertEqual(candles.count, 24 * 60)

            case .failure:
                XCTFail("wrong error")
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownloadCandles_1() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let provider = CandlesProvider()

        let begin = formatter.date(from: "01-01-2020 00:00")!
        let end = formatter.date(from: "04-01-2020 00:00")!

        try? provider.fetch(for: "EURUSD", range: begin ..< end, completion: { result in

            switch result {
            case let .success(candles):

                XCTAssertEqual(candles.count, 3 * 24 * 60)

            case .failure:
                XCTFail("wrong error")
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }
}

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

private let accuracyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.timeZone = utc
    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSSS"
    return formatter
}()
