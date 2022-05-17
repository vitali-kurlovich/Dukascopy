//
//  CandlesDecoder.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/19/20.
//

import Foundation

import DukascopyDecoder

internal
extension CandlesDecoder {
    typealias CandelsType = DukascopyCandlesCollection.CandelsType

    func decode(with data: Data, start: Date, type: CandelsType) throws -> DukascopyCandlesCollection {
        let candles = try decode(with: data)

        return .init(type: type, date: start, candles: candles)
    }
}
