//
//  DukascopyCandle.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/19/20.
//

import Foundation

internal
struct DukascopyCandle: Equatable {
    struct Price: Equatable {
        let open: Int32
        let close: Int32
        let low: Int32
        let high: Int32
    }

    let time: Int32
    let price: Price
    let volume: Float32
}

internal
struct DukascopyCandlesCollection: Equatable {
    enum CandelsType: Int, Equatable {
        case ask
        case bid
    }

    let type: CandelsType
    let date: Date
    var candles: [DukascopyCandle]
}

internal
struct DukascopyBidAskCandle: Equatable {
    typealias Price = DukascopyCandle.Price
    let time: Int32
    let askPrice: Price
    let bidPrice: Price
    let askVolume: Float32
    let bidVolume: Float32
}

extension DukascopyCandlesCollection {
    mutating
    func append<S: Sequence>(contentsOf: S) where S.Element == DukascopyCandle {
        candles.append(contentsOf: contentsOf)
    }

    mutating
    func append(_ collection: DukascopyCandlesCollection) {
        assert(type == collection.type)

        let delta = collection.date.timeIntervalSince(date)

        let increment = Int32(round(delta * 1000))

        if increment == 0 {
            append(contentsOf: collection.candles)
        } else {
            let candles = collection.candles.lazy.map { (candle) -> DukascopyCandle in

                .init(time: candle.time + increment, price: candle.price, volume: candle.volume)
            }

            append(contentsOf: candles)
        }
    }
}
