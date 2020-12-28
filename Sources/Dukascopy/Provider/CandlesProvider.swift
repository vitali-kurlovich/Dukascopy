//
//  DukascopyProvider.swift
//  Chart
//
//  Created by Vitali Kurlovich on 3/12/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import DukascopyDecoder
import DukascopyDownloader
import Foundation

@available(OSX 10.11, *)
class CandlesProvider {
    enum ProviderError: Swift.Error {
        case invalidData
    }

    private let downloader = DukascopyDownloader()

    private let candlesDecoder = CandlesDecoder()
}

@available(OSX 10.11, *)
extension CandlesProvider {
    public
    func fetch(for currency: String, range: Range<Date>, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        try fetch(type: .ask, for: currency, range: range) { result in
            switch result {
            case let .success(ask):
                if ask.candles.isEmpty {
                    completion?(.success(.init(date: ask.date, candles: [], period: TimeInterval(60))))
                    return
                }

                do {
                    try self.fetch(type: .bid, for: currency, range: range) { result in

                        switch result {
                        case let .success(bid):
                            let collection = self.candlesCollection(ask: ask, bid: bid, period: TimeInterval(60))

                            completion?(.success(collection))

                        case let .failure(error):
                            completion?(.failure(error))
                        }
                    }

                } catch {
                    completion?(.failure(error))
                }

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    public
    func fetch(for currency: String, date: Date, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        let comps = ProviderCalendar.calendar.dateComponents([.year, .month, .day], from: date)

        try fetch(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, completion: completion)
    }

    private
    func fetch(for currency: String, year: Int, month: Int, day: Int, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        try fetch(type: .ask, for: currency, year: year, month: month, day: day) { result in
            switch result {
            case let .success(ask):
                if ask.candles.isEmpty {
                    completion?(.success(.init(date: ask.date, candles: [], period: TimeInterval(60))))
                    return
                }

                do {
                    try self.fetch(type: .bid, for: currency, year: year, month: month, day: day) { result in

                        switch result {
                        case let .success(bid):
                            let collection = self.candlesCollection(ask: ask, bid: bid, period: TimeInterval(60))

                            completion?(.success(collection))

                        case let .failure(error):
                            completion?(.failure(error))
                        }
                    }

                } catch {
                    completion?(.failure(error))
                }

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}

@available(OSX 10.11, *)
extension CandlesProvider {
    private typealias CandelsType = CandlesDecoder.CandelsType

    private
    func fetch(type: CandelsType, for currency: String, year: Int, month: Int, day: Int, completion: ((Result<DukascopyCandlesCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .candles(type == .ask ? .ask : .bid), for: currency, year: year, month: month, day: day) { result in
            switch result {
            case let .success((data, range)):
                do {
                    let chunks = try self.decodeCandles(data, date: range.lowerBound, type: type)

                    completion?(.success(chunks))
                } catch {
                    completion?(.failure(error))
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    private
    func fetch(type: CandelsType, for currency: String, range: Range<Date>, completion: ((Result<DukascopyCandlesCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .candles(type == .ask ? .ask : .bid), for: currency, range: range) { result in
            switch result {
            case let .success(items):

                do {
                    let candles = try items.compactMap { (result) -> DukascopyCandlesCollection? in
                        switch result {
                        case let .success((data, range)):
                            return try self.decodeCandles(data, date: range.lowerBound, type: type)

                        case let .failure(error):
                            throw error
                        }
                    }

                    var result = candles.first!

                    for item in candles.dropFirst() {
                        result.append(item)
                    }

                    completion?(.success(result))
                } catch {
                    completion?(.failure(error))
                }

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    private
    func candlesCollection(ask: DukascopyCandlesCollection,
                           bid: DukascopyCandlesCollection,
                           period: TimeInterval = TimeInterval(60)) -> CandlesCollection
    {
        let date = ask.date

        if ask.candles.isEmpty {
            return .init(date: date, candles: [], period: period)
        }

        var askIterator = ask.candles.makeIterator()
        var bidIterator = bid.candles.makeIterator()

        var askCandle = askIterator.next()
        var bidCandle = bidIterator.next()

        var candles = [DukascopyBidAskCandle]()
        candles.reserveCapacity(ask.candles.underestimatedCount)

        while let ask = askIterator.next() {
            let bid = bidIterator.next()!

            candles.append(
                .init(time: askCandle!.time,
                      askPrice: askCandle!.price,
                      bidPrice: bidCandle!.price,
                      askVolume: askCandle!.volume,
                      bidVolume: bidCandle!.volume))

            askCandle = ask
            bidCandle = bid
        }

        candles.append(
            .init(time: askCandle!.time,
                  askPrice: askCandle!.price,
                  bidPrice: bidCandle!.price,
                  askVolume: askCandle!.volume,
                  bidVolume: bidCandle!.volume))

        return .init(date: date,
                     candles: candles,
                     period: period)
    }
}

@available(OSX 10.11, *)
extension CandlesProvider {
    private
    func decodeCandles(_ data: Data, date: Date, type: CandlesDecoder.CandelsType) throws -> DukascopyCandlesCollection {
        try candlesDecoder.decode(with: data, start: date, type: type)
    }

    private
    func decodeCandles(_ fileURL: URL, date: Date, type: CandlesDecoder.CandelsType) throws -> DukascopyCandlesCollection {
        let data = try Data(contentsOf: fileURL)

        return try decodeCandles(data, date: date, type: type)
    }
}
