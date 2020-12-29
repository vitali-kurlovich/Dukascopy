//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 29.12.20.
//

import Foundation

import XCTest

struct FormatterUtils {
    private static let utc = TimeZone(identifier: "UTC")!

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar
    }()

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = utc
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        return formatter
    }()

    static let accuracyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = utc
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss.SSSS"
        return formatter
    }()
}
