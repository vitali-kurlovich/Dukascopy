//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 25.12.20.
//

import Foundation

struct ProviderCalendar {
    private static let utc = TimeZone(identifier: "UTC")!

    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar
    }()
}
