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
    internal let date: Date
    internal var ticks: [DukascopyTick]

    public var bounds: Range<Date> {
        guard let first = ticks.first, let last = ticks.last else {
            return date ..< date
        }

        return tick(date: date, first).date ..< tick(date: date, last).date
    }
}

extension TicksCollection {
    internal mutating
    func append(_ tick: DukascopyTick) {
        ticks.append(tick)
    }

    internal mutating
    func append<S: Sequence>(contentsOf: S) where S.Element == DukascopyTick {
        ticks.append(contentsOf: contentsOf)
    }

    internal mutating
    func append(_ collection: TicksCollection) {
        let delta = collection.date.timeIntervalSince(date)

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

    internal mutating
    func append(_ collection: SliceTicksCollection) {
        let delta = collection.date.timeIntervalSince(date)

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
        return tick(date: date, block)
    }

    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        let date = self.date
        let slice = ticks[bounds]
        return SubSequence(date: date, ticks: slice)
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
    internal let date: Date
    internal let ticks: ArraySlice<DukascopyTick>

    public var bounds: Range<Date> {
        guard let first = ticks.first, let last = ticks.last else {
            return date ..< date
        }

        return tick(date: date, first).date ..< tick(date: date, last).date
    }
}

extension SliceTicksCollection: Equatable {}

extension SliceTicksCollection: BidirectionalCollection {
    public typealias Element = Tick

    public typealias Index = Int

    public typealias SubSequence = SliceTicksCollection

    public subscript(position: Int) -> Self.Element {
        let item = ticks[position]
        return tick(date: date, item)
    }

    public subscript(bounds: Range<Self.Index>) -> Self.SubSequence {
        let date = self.date
        let slice = ticks[bounds]
        return SubSequence(date: date, ticks: slice)
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
