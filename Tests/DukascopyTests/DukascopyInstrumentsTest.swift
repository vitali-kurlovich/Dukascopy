//
//  DukascopyInstrumentsTest.swift
//  DukascopyTests
//
//  Created by Vitali Kurlovich on 4/17/20.
//

@testable import Dukascopy
import XCTest

struct Group: Decodable {
    let id: String
    let title: String
    let parent: String?
    let instruments: [String]?
}

struct Instruments: Decodable {
    let title: String?
    let name: String
    let description: String
    let filename: String?

    let pipValue: Double
    let baseCurrency: String?
    let quoteCurrency: String?
    let commoditiesPerContract: String?
    let tags: [String]

    let history_start_tick: Date
    let history_start_10sec: Date
    let history_start_60sec: Date
    let history_start_60min: Date
    let history_start_day: Date

    private enum CodingKeys: String, CodingKey {
        case title
        case name
        case description
        case filename = "historical_filename"

        case pipValue
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
        case commoditiesPerContract = "commodities_per_contract"
        case tags = "tag_list"

        case history_start_tick
        case history_start_10sec
        case history_start_60sec
        case history_start_60min
        case history_start_day
    }

    //
}

struct Info: Decodable {
    let groups: [String: Group]
    let instruments: [String: Instruments]
}

class DukascopyInstrumentsTest: XCTestCase {
    func testDecode() throws {
        let jsonData = MocInstrumentsInfo().jsonData
        XCTAssertFalse(jsonData.isEmpty)

        let data = jsonData.dropFirst("jsonp(".count).dropLast()

        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .custom { (decoder) -> Date in

            let container = try decoder.singleValueContainer()
            let timeInterval = TimeInterval(try container.decode(String.self))! / TimeInterval(1000)

            return Date(timeIntervalSince1970: timeInterval)
        }

        let info = try? decoder.decode(Info.self, from: data)

        // print(info)

        let instruments = info?.instruments

        XCTAssertFalse(instruments?.isEmpty ?? true)

        //  print(instruments)
    }
}
