//
//  DukascopyProviderTests.swift
//  DukascopyTests
//
//  Created by Vitali Kurlovich on 4/16/20.
//

@testable import Dukascopy
import DukascopyModel
import XCTest

private let provider = DukascopyTicksProvider()
private let formatter = FormatterUtils.formatter
private let accuracyFormatter = FormatterUtils.accuracyFormatter

final class DukascopyTicksProviderTests: XCTestCase {
    func testDownload() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let date = formatter.date(from: "01-01-2020 22:00")!

        try? provider.fetch(for: "EURUSD", date: date, completion: { result in

            switch result {
            case let .success(container):
                let ticks = container.ticks

                XCTAssertEqual(ticks.count, 1423)

                XCTAssertEqual(ticks[0].askp, 112_160)
                XCTAssertEqual(ticks[0].time, (60 + 12) * 1000 + 821)

                XCTAssertEqual(ticks[5].time, (60 + 21) * 1000 + 124)
                XCTAssertEqual(ticks[5].askp, 112_161)
                XCTAssertEqual(ticks[5].bidp, 112_122)

                XCTAssertEqual(ticks[5].askv, 0.0937, accuracy: 0.001)
                XCTAssertEqual(ticks[5].bidv, 0.75, accuracy: 0.001)

                let last = ticks.last!

                XCTAssertEqual(last.time, (59 * 60 + 50) * 1000 + 894)
                XCTAssertEqual(last.askp, 112_157)
                XCTAssertEqual(last.bidp, 112_143)

                XCTAssertEqual(last.askv, 0.19, accuracy: 0.001)
                XCTAssertEqual(last.bidv, 0.75, accuracy: 0.001)

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownload_1() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

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

                XCTAssertEqual(first.time, (60 + 12) * 1000 + 821)
                XCTAssertEqual(first.askp, 112_160)
                XCTAssertEqual(first.bidp, 112_106)

                XCTAssertEqual(first.askv, 0.0937, accuracy: 0.001)
                XCTAssertEqual(first.bidv, 0.75, accuracy: 0.001)

                // 01.01.2020 23:59:54.234,1.1219100000000002,1.12188,0.19,0.19

                let last = ticks.last!
                let time = (3600 + 59 * 60 + 54) * 1000 + 234
                XCTAssertEqual(last.time, Int32(time))
                XCTAssertEqual(last.askp, 112_191)
                XCTAssertEqual(last.bidp, 112_188)

                XCTAssertEqual(last.askv, 0.19, accuracy: 0.001)
                XCTAssertEqual(last.bidv, 0.19, accuracy: 0.001)

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }

            expectation.fulfill()
        })
        wait(for: [expectation], timeout: 10.0)
    }
}
