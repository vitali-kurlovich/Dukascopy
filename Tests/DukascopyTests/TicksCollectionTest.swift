//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 4/14/20.
//

@testable import Dukascopy
import XCTest

final class TicksCollectionTest: XCTestCase {
    func testCollection() {
        let date = formatter.date(from: "04-04-2019 11:00")!

        let range = date ..< formatter.date(from: "04-04-2019 12:00")!

        let bloks: [DukascopyTick] = [
            .init(time: 12, askp: 12000, bidp: 12004, askv: 0.1, bidv: 0.1),
            .init(time: 120, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 12320, askp: 12100, bidp: 12104, askv: 0.1, bidv: 0.1),
        ]

        let emptyCollection = TicksCollection(range: range, ticks: [])

        XCTAssertTrue(emptyCollection.bounds.isEmpty)

        var collection = TicksCollection(range: range, ticks: bloks)

        XCTAssertEqual(collection.count, 3)

        XCTAssertEqualDate(collection.bounds.lowerBound, accuracyFormatter.date(from: "04-04-2019 11:00:00.012")!)

        XCTAssertEqualDate(collection.bounds.upperBound, accuracyFormatter.date(from: "04-04-2019 11:00:12.320")!)

        let bloks2: [DukascopyTick] = [
            .init(time: 15002, askp: 15000, bidp: 15004, askv: 0.1, bidv: 0.1),
            .init(time: 16045, askp: 16200, bidp: 16304, askv: 0.23, bidv: 0.1),
            .init(time: 18320, askp: 16100, bidp: 17104, askv: 0.1, bidv: 0.12),
        ]

        let collection2 = TicksCollection(range: range, ticks: bloks2)

        collection.append(collection2)

        XCTAssertEqual(collection.count, 6)

        XCTAssertEqualDate(collection.bounds.upperBound, accuracyFormatter.date(from: "04-04-2019 11:00:18.320")!)

        let bloks3: [DukascopyTick] = [
            .init(time: 25, askp: 14000, bidp: 14004, askv: 0.1, bidv: 0.1),
            .init(time: 45, askp: 13200, bidp: 13304, askv: 0.23, bidv: 0.1),
            .init(time: 112, askp: 12200, bidp: 12104, askv: 0.1, bidv: 0.12),
        ]

        let range2 = formatter.date(from: "04-04-2019 11:10")! ..< formatter.date(from: "04-04-2019 12:00")!
        let collection3 = TicksCollection(range: range2, ticks: bloks3)

        XCTAssertEqualDate(collection3.bounds.lowerBound,
                           accuracyFormatter.date(from: "04-04-2019 11:10:00.025")!, accuracy: 0.001)

        XCTAssertEqualDate(collection3.bounds.upperBound,
                           accuracyFormatter.date(from: "04-04-2019 11:10:00.112")!, accuracy: 0.001)

        collection.append(collection3)

        XCTAssertEqual(collection.count, 9)
        XCTAssertEqualDate(collection.bounds.upperBound, collection3.bounds.upperBound, accuracy: 0.001)

        let begin = collection.index(collection.startIndex, offsetBy: 2)

        let end = collection.index(collection.startIndex, offsetBy: 8)

        let sliceRange = begin ..< end

        let slice = collection[sliceRange]

        XCTAssertEqualDate(slice.bounds.lowerBound, accuracyFormatter.date(from: "04-04-2019 11:00:12.320")!)

        XCTAssertEqualDate(slice.bounds.upperBound, accuracyFormatter.date(from: "04-04-2019 11:10:00.045")!)
    }

    func testCollection_1() {
        let date = formatter.date(from: "04-04-2019 11:30")!
        let range = date ..< formatter.date(from: "04-04-2019 12:00")!

        let ticks: [DukascopyTick] = [
            .init(time: 12, askp: 12000, bidp: 12004, askv: 0.1, bidv: 0.1),
            .init(time: 120, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 540, askp: 12100, bidp: 12104, askv: 0.1, bidv: 0.1),
        ]

        var collection = TicksCollection(range: range, ticks: ticks)

        let ticksSliced: [DukascopyTick] = [
            .init(time: 1012, askp: 12000, bidp: 12004, askv: 0.1, bidv: 0.1),
            .init(time: 10120, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 10540, askp: 12100, bidp: 12104, askv: 0.1, bidv: 0.1),
        ]

        let s = TicksCollection(range: range, ticks: ticksSliced)[1 ..< 2]
        collection.append(s)

        let ticks_2: [DukascopyTick] = [
            .init(time: 13, askp: 12000, bidp: 12004, askv: 0.1, bidv: 0.1),
            .init(time: 127, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 2227, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 5467, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 6667, askp: 12200, bidp: 12304, askv: 0.1, bidv: 0.1),
            .init(time: 8746, askp: 12100, bidp: 12104, askv: 0.1, bidv: 0.1),
        ]

        let date2 = formatter.date(from: "04-04-2019 12:00")!

        let range2 = date2 ..< formatter.date(from: "04-04-2019 13:00")!

        let collection2 = TicksCollection(range: range2, ticks: ticks_2)

        let begin = collection2.index(collection2.startIndex, offsetBy: 1)

        let end = collection2.index(collection2.startIndex, offsetBy: 5)

        let slice = collection2[begin ..< end]

        XCTAssertEqualDate(slice.bounds.lowerBound, accuracyFormatter.date(from: "04-04-2019 12:00:00.127")!)

        XCTAssertEqualDate(slice.bounds.upperBound, accuracyFormatter.date(from: "04-04-2019 12:00:06.667")!)

        collection.append(slice)

        XCTAssertEqualDate(collection.bounds.lowerBound, accuracyFormatter.date(from: "04-04-2019 11:30:00.012")!)

        XCTAssertEqualDate(collection.bounds.upperBound, accuracyFormatter.date(from: "04-04-2019 12:00:06.667")!)

        XCTAssertEqual(collection.count, 8)
    }

    static var allTests = [
        ("testCollection", testCollection),
        ("testCollection_1", testCollection_1),
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

private let accuracyFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.timeZone = utc
    formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSSS"
    return formatter
}()
