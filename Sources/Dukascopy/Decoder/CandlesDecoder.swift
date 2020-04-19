//
//  CandlesDecoder.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/19/20.
//

import Foundation

internal
final class CandlesDecoder {
    typealias CandelsType = DukascopyCandlesCollection.CandelsType

    @available(OSX 10.11, *)
    func decode(with data: Data, start: Date, type: CandelsType) throws -> DukascopyCandlesCollection {
        if data.isEmpty {
            return .init(type: type, date: start, candles: [])
        }

        guard let decompressed = data.decompress() else {
            throw DecoderError.decompressError
        }

        struct _Block {
            let time: Int32
            let open: Int32
            let close: Int32
            let low: Int32
            let high: Int32
            let volume: UInt32
        }

        let candles = decompressed.withUnsafeBytes { (pointer) -> [DukascopyCandle] in
            let memory = pointer.bindMemory(to: _Block.self)

            var candles = [DukascopyCandle]()
            candles.reserveCapacity(memory.underestimatedCount)

            for block in memory {
                let time = block.time.bigEndian
                let open = block.open.bigEndian
                let close = block.close.bigEndian
                let low = block.low.bigEndian
                let high = block.high.bigEndian
                let volume = Float32(bitPattern: block.volume.bigEndian)

                let price = DukascopyCandle.Price(open: open, close: close, low: low, high: high)

                candles.append(.init(time: time, price: price, volume: volume))
            }

            return candles
        }

        return .init(type: type, date: start, candles: candles)
    }
}
