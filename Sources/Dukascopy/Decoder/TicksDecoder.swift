//
//  DukascopyDecoder.swift
//  Chart
//
//  Created by Vitali Kurlovich on 3/12/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

import DukascopyDecoder

internal
extension TicksDecoder {
    @available(OSX 10.11, *)
    func decode(with data: Data, range: Range<Date>) throws -> TicksCollection {
        let blocks = try decode(with: data)
        return TicksCollection(range: range, ticks: blocks)
    }
}
