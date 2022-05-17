//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 29.12.20.
//

@testable import Dukascopy
import DukascopyModel
import XCTest

private let provider = CandlesProvider()

private let formatter = FormatterUtils.formatter
private let accuracyFormatter = FormatterUtils.accuracyFormatter

final class DukascopyCandlesProviderTests: XCTestCase {
    func testDownload() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let date = formatter.date(from: "01-01-2020 22:00")!

        try? provider.fetch(for: "EURUSD", date: date, completion: { result in

            switch result {
            case let .success(candles):

                XCTAssertEqual(candles.count, 24 * 60)

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownload_1() throws {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let begin = formatter.date(from: "01-01-2020 00:00")!
        let end = formatter.date(from: "04-01-2020 00:00")!

        try? provider.fetch(for: "EURUSD", range: begin ..< end, completion: { result in

            switch result {
            case let .success(candles):

                XCTAssertEqual(candles.count, 3 * 24 * 60)

            case let .failure(error):
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 10.0)
    }
}
