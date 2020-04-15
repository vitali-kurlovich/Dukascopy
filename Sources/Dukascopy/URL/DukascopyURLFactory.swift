//
//  DukascopyURLFactory.swift
//  Chart
//
//  Created by Vitali Kurlovich on 4/4/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

public
final class DukascopyURLFactory {
    public
    enum FactoryError: Error {
        case invalidURL
        case invalidCurrency
        case invalidMonth
        case invalidDay
        case invalidHour
        case invalidDate
        case invalidDateRange
    }

    private let baseUrlTemplate: String

    public
    init(_ baseUrlTemplate: String = "https://www.dukascopy.com/datafeed/%s/%d/%02d/%02d/%02dh_ticks.bi5") {
        self.baseUrlTemplate = baseUrlTemplate
    }

    public
    func url(for currency: String, range: Range<Date>) throws -> [(url: URL, date: Date)] {
        guard !currency.isEmpty else {
            throw FactoryError.invalidCurrency
        }

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.lowerBound)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.upperBound)

        guard let lower = calendar.date(from: lowerComps),
            let upper = calendar.date(from: upperComps) else {
            throw FactoryError.invalidDateRange
        }

        var urls = [(url: URL, date: Date)]()
        let hour = DateComponents(hour: 1)
        var current = lower

        if let url = try? url(for: currency, date: current) {
            urls.append((url: url, date: current))
        }

        while let next = calendar.date(byAdding: hour, to: current), next < upper {
            current = next

            if let url = try? url(for: currency, date: current) {
                urls.append((url: url, date: current))
            }
        }

        return urls
    }

    public
    func url(for currency: String, date: Date) throws -> URL {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return try url(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }

    public
    func url(for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URL {
        guard (1 ... 12).contains(month) else {
            throw FactoryError.invalidMonth
        }

        guard (1 ... 31).contains(day) else {
            throw FactoryError.invalidDay
        }

        guard (0 ... 23).contains(hour) else {
            throw FactoryError.invalidHour
        }

        let currency = currency.uppercased()

        guard !currency.isEmpty else {
            throw FactoryError.invalidCurrency
        }

        var comps = DateComponents()
        comps.year = year
        comps.day = day
        comps.month = month

        guard let date = calendar.date(from: comps), date < Date() else {
            throw FactoryError.invalidDate
        }

        let new = calendar.dateComponents([.year, .month, .day], from: date)

        guard comps == new else {
            throw FactoryError.invalidDate
        }

        let baseUrl = String(format: baseUrlTemplate, currency, year, month - 1, day, hour)

        guard let url = URL(string: baseUrl) else {
            throw FactoryError.invalidURL
        }

        return url
    }
}

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()
