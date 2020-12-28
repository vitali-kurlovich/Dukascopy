//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 4/14/20.
//

import Foundation

// CandlesDecoder

public
struct TicksCollection: TicksSequence {
    public let range: Range<Date>
    internal var ticks: [DukascopyTick]

    public var bounds: Range<Date> {
        guard let first = ticks.first, let last = ticks.last else {
            return range.lowerBound ..< range.lowerBound
        }

        let date = range.lowerBound

        return tick(date: date, first).date ..< tick(date: date, last).date
    }
}

extension TicksCollection {
    mutating
    func append(_ tick: DukascopyTick) {
        ticks.append(tick)
    }

    mutating
    func append<S: Sequence>(contentsOf: S) where S.Element == DukascopyTick {
        ticks.append(contentsOf: contentsOf)
    }

    mutating
    func append(_ collection: TicksCollection) {
        let delta = collection.range.lowerBound.timeIntervalSince(range.lowerBound)

        let increment = Int32(round(delta * 1000))

        if increment == 0 {
            append(contentsOf: collection.ticks)
        } else {
            let ticks = collection.ticks.lazy.map { (tick) -> DukascopyTick in
                .init(time: tick.time + increment,
                      askp: tick.askp, bidp: tick.bidp,
                      askv: tick.askv, bidv: tick.bidv)
            }

            append(contentsOf: ticks)
        }
    }

    mutating
    func append(_ collection: SliceTicksCollection) {
        let delta = collection.range.lowerBound.timeIntervalSince(range.lowerBound)

        let increment = Int32(round(delta * 1000))

        if increment == 0 {
            append(contentsOf: collection.ticks)
        } else {
            let ticks = collection.ticks.lazy.map { (tick) -> DukascopyTick in
                .init(time: tick.time + increment,
                      askp: tick.askp, bidp: tick.bidp,
                      askv: tick.askv, bidv: tick.bidv)
            }

            append(contentsOf: ticks)
        }
    }
}

extension TicksCollection: Equatable {}

extension TicksCollection: BidirectionalCollection {
    public typealias Element = Tick

    public typealias Index = Int

    public typealias SubSequence = SliceTicksCollection

    public subscript(position: Int) -> Self.Element {
        let block = ticks[position]
        let date = range.lowerBound
        return tick(date: date, block)
    }

    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        // let date = range.lowerBound
        let slice = ticks[bounds]

        return SubSequence(range: range, ticks: slice)
    }

    public func index(before i: Int) -> Int {
        ticks.index(before: i)
    }

    public func index(after i: Int) -> Int {
        ticks.index(after: i)
    }

    public var startIndex: Int {
        ticks.startIndex
    }

    public var endIndex: Int {
        ticks.endIndex
    }
}

public
struct SliceTicksCollection: TicksSequence {
    public let range: Range<Date>
    internal let ticks: ArraySlice<DukascopyTick>

    public var bounds: Range<Date> {
        guard let first = ticks.first, let last = ticks.last else {
            return range.lowerBound ..< range.lowerBound
        }

        return tick(date: range.lowerBound, first).date ..< tick(date: range.lowerBound, last).date
    }
}

extension SliceTicksCollection: Equatable {}

extension SliceTicksCollection: BidirectionalCollection {
    public typealias Element = Tick

    public typealias Index = Int

    public typealias SubSequence = SliceTicksCollection

    public subscript(position: Int) -> Self.Element {
        let item = ticks[position]
        return tick(date: range.lowerBound, item)
    }

    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        let slice = ticks[bounds]
        return SubSequence(range: range, ticks: slice)
    }

    public func index(before i: Int) -> Int {
        ticks.index(before: i)
    }

    public func index(after i: Int) -> Int {
        ticks.index(after: i)
    }

    public var startIndex: Int {
        ticks.startIndex
    }

    public var endIndex: Int {
        ticks.endIndex
    }
}

private func tick(date: Date, _ block: DukascopyTick) -> Tick {
    let deltaTime = TimeInterval(block.time) / 1000

    let date = date.addingTimeInterval(deltaTime)

    let price = Price(ask: block.askp, bid: block.bidp)
    let volume = Volume(ask: block.askv, bid: block.bidv)

    return Tick(date: date, price: price, volume: volume)
}
