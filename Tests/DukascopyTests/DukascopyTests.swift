@testable import Dukascopy
import XCTest

final class DukascopyTests: XCTestCase {
    func testDownloadData() {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let downloader = DukascopyDownloader()

        let date = formatter.date(from: "04-04-2019 11:00")!

        try? downloader.download(for: "EURUSD", date: date) { result in

            switch result {
            case let .success((data, time)):
                XCTAssertEqual(time, date)
                XCTAssertEqual(data.count, 50435)
            case .failure:
                XCTFail("wrong error")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownloadData_1() {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let downloader = DukascopyDownloader()

        let date = formatter.date(from: "06-01-2019 12:00")!

        try? downloader.download(for: "EURUSD", date: date) { result in

            switch result {
            case let .success((data, time)):
                XCTAssertEqual(time, date)
                XCTAssertTrue(data.isEmpty)
            case .failure:
                XCTFail("wrong error")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func testDownloadData_2() {
        let expectation = XCTestExpectation(description: "Download Dukacopy bi5 file")

        let downloader = DukascopyDownloader()

        let begin = formatter.date(from: "04-04-2019 11:00")!
        let end = formatter.date(from: "04-04-2019 19:00")!

        try? downloader.download(for: "EURUSD", range: begin ..< end) { result in

            switch result {
            case let .success(items):
                XCTAssertEqual(items.count, 8)

            case .failure:
                XCTFail("wrong error")
            }

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    static var allTests = [
        ("testDownloadData", testDownloadData),
        ("testDownloadData_1", testDownloadData_1),
        ("testDownloadData_2", testDownloadData_2),
    ]
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
