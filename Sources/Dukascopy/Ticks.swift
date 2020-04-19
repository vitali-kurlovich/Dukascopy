//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 4/14/20.
//

import Foundation

public
struct Tick: Equatable {
    public let date: Date
    public let price: Price
    public let volume: Volume
}

public
struct Price: Equatable {
    public let ask: Int32
    public let bid: Int32
}

public
struct Volume: Equatable {
    public let ask: Float32
    public let bid: Float32
}

public protocol TicksSequence: Sequence where Self.Element == Tick {
    var bounds: Range<Date> { get }
}

public
struct Candle: Equatable {
    public let period: Range<Date>
    public let open: Price
    public let close: Price
    public let high: Price
    public let low: Price
    public let volume: Volume
}

public protocol CandlesSequence: Sequence where Self.Element == Candle {
    var bounds: Range<Date> { get }
}
