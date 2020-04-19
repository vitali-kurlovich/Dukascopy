//
//  DukascopyDecoder.swift
//  Chart
//
//  Created by Vitali Kurlovich on 3/12/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

public
enum DecoderError: Error {
    case decompressError
}

internal
final class TicksDecoder {
    @available(OSX 10.11, *)
    func decode(with data: Data, start: Date) throws -> TicksCollection {
        if data.isEmpty {
            return TicksCollection(date: start, ticks: [])
        }

        guard let decompressed = data.decompress() else {
            throw DecoderError.decompressError
        }

        struct _Block {
            let time: Int32
            let askp: Int32
            let bidp: Int32
            let askv: UInt32
            let bidv: UInt32
        }

        return decompressed.withUnsafeBytes { (pointer) -> TicksCollection in
            let memory = pointer.bindMemory(to: _Block.self)

            var blocks = [DukascopyTick]()
            blocks.reserveCapacity(memory.underestimatedCount)

            for block in memory {
                let time = block.time.bigEndian
                let askp = block.askp.bigEndian
                let bidp = block.bidp.bigEndian

                let askv = block.askv.bigEndian
                let bidv = block.bidv.bigEndian

                let askV = Float32(bitPattern: askv)
                let bidV = Float32(bitPattern: bidv)

                blocks.append(.init(time: time, askp: askp, bidp: bidp, askv: askV, bidv: bidV))
            }

            return TicksCollection(date: start, ticks: blocks)
        }
    }
}
