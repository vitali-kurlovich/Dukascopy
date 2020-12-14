//
//  Candle.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/20/20.
//

import Foundation

public
struct Candle: Equatable {
    public let period: Range<Date>
    public let open: Price
    public let close: Price
    public let high: Price
    public let low: Price
    public let volume: Volume
}
