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

    static var allTests = [
        ("testDownloadData", testDownloadData),
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
    formatter.dateFormat = "MM-dd-yyyy HH:mm"
    return formatter
}()