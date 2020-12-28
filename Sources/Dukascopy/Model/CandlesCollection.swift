//
//  CandlesCollection.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/19/20.
//

import Foundation

public
struct CandlesCollection: CandlesSequence {
    internal let date: Date
    internal var candles: [DukascopyBidAskCandle]
    internal let period: TimeInterval

    public var bounds: Range<Date> {
        guard let first = candles.first, let last = candles.last else {
            return date ..< date
        }

        let firstCandle = candle(date: date, first, period: period)
        let lastCandle = candle(date: date, last, period: period)

        return firstCandle.period.lowerBound ..< lastCandle.period.upperBound
    }
}

extension CandlesCollection: Equatable {}

extension CandlesCollection: BidirectionalCollection {
    public typealias Element = Candle

    public typealias Index = Int

    public subscript(position: Int) -> Candle {
        let item = candles[position]
        return candle(date: date, item, period: period)
    }

    public func index(before i: Int) -> Int {
        candles.index(before: i)
    }

    public func index(after i: Int) -> Int {
        candles.index(after: i)
    }

    public var startIndex: Int {
        candles.startIndex
    }

    public var endIndex: Int {
        candles.endIndex
    }
}

extension CandlesCollection {
    mutating
    func append<S: Sequence>(contentsOf: S) where S.Element == DukascopyBidAskCandle {
        candles.append(contentsOf: contentsOf)
    }
}

private func candle(date: Date, _ block: DukascopyBidAskCandle, period: TimeInterval) -> Candle {
    let deltaTime = TimeInterval(block.time) / 1000

    let date = date.addingTimeInterval(deltaTime)

    let open = Price(ask: block.askPrice.open, bid: block.bidPrice.open)
    let close = Price(ask: block.askPrice.close, bid: block.bidPrice.close)
    let high = Price(ask: block.askPrice.high, bid: block.bidPrice.high)
    let low = Price(ask: block.askPrice.low, bid: block.bidPrice.low)
    let volume = Volume(ask: block.askVolume, bid: block.bidVolume)

    return Candle(period: date ..< date.addingTimeInterval(period),
                  open: open,
                  close: close,
                  high: high,
                  low: low,
                  volume: volume)
}
