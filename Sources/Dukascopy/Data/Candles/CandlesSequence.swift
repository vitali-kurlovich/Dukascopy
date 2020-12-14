//
//  CandlesSequence.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/20/20.
//

import Foundation

public protocol CandlesSequence: Sequence where Self.Element == Candle {
    var bounds: Range<Date> { get }
}

struct CandlesAdapter<Input: TicksSequence>: CandlesSequence {
    let ticksSequence: Input
    let period: TimeInterval

    typealias Iterator = CandlesAdapterIterator<Input>

    var bounds: Range<Date> {
        ticksSequence.bounds
    }

    func makeIterator() -> Iterator {
        Iterator(ticksSequence: ticksSequence, period: period)
    }
}

struct CandlesAdapterIterator<Input: TicksSequence>: IteratorProtocol {
    typealias Element = Candle

    let ticksSequence: Input
    let period: TimeInterval

    mutating func next() -> Candle? {
        nil
    }
}
