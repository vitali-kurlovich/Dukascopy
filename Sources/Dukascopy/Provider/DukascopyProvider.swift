//
//  DukascopyProvider.swift
//  Chart
//
//  Created by Vitali Kurlovich on 3/12/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation
import DukascopyURL

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@available(OSX 10.11, *)
class DukascopyProvider {
    enum ProviderError: Swift.Error {
        case invalidData
    }

    private let urlFactory = URLFactory()

    private let downloader = DukascopyDownloader()

    private let ticksDecoder = TicksDecoder()
    private let candlesDecoder = CandlesDecoder()
}

@available(OSX 10.11, *)
extension DukascopyProvider {
    public
    func fetchCandles(for currency: String, range: Range<Date>, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        try fetchCandles(type: .ask, for: currency, range: range) { result in
            switch result {
            case let .success(ask):
                if ask.candles.isEmpty {
                    completion?(.success(.init(date: ask.date, candles: [], period: TimeInterval(60))))
                    return
                }

                do {
                    try self.fetchCandles(type: .bid, for: currency, range: range) { result in

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
    func fetchCandles(for currency: String, date: Date, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)

        try fetchCandles(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, completion: completion)
    }

    public
    func fetchCandles(for currency: String, year: Int, month: Int, day: Int, completion: ((Result<CandlesCollection, Error>) -> Void)? = nil) throws {
        try fetchCandles(type: .ask, for: currency, year: year, month: month, day: day) { result in
            switch result {
            case let .success(ask):
                if ask.candles.isEmpty {
                    completion?(.success(.init(date: ask.date, candles: [], period: TimeInterval(60))))
                    return
                }

                do {
                    try self.fetchCandles(type: .bid, for: currency, year: year, month: month, day: day) { result in

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
extension DukascopyProvider {
    func fetchTicks(for currency: String, range: Range<Date>, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .ticks, for: currency, range: range) { result in
            switch result {
            case let .success(result):

                var ticks: TicksCollection?

                for item in result {
                    switch item {
                    case let .success(duka):
                        do {
                            let chunk = try self.decodeTicks(duka.data, range: duka.range)

                            if ticks == nil {
                                ticks = chunk
                            } else {
                                ticks?.append(chunk)
                            }

                        } catch {
                            completion?(.failure(error))
                        }

                    case let .failure(error):
                        completion?(.failure(error))
                    }
                }

                completion?(.success(ticks!))

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    func fetchTicks(for currency: String, date: Date, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        try fetchTicks(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!, completion: completion)
    }

    func fetchTicks(for currency: String, year: Int, month: Int, day: Int, hour: Int, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .ticks, for: currency, year: year, month: month, day: day, hour: hour) { result in
            switch result {
            case let .success((data, range)):
                do {
                    let chunks = try self.decodeTicks(data, range: range)
                    completion?(.success(chunks))
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
extension DukascopyProvider {
    private typealias CandelsType = CandlesDecoder.CandelsType

    private
    func fetchCandles(type: CandelsType, for currency: String, year: Int, month: Int, day: Int, completion: ((Result<DukascopyCandlesCollection, Error>) -> Void)? = nil) throws {
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
    func fetchCandles(type: CandelsType, for currency: String, range: Range<Date>, completion: ((Result<DukascopyCandlesCollection, Error>) -> Void)? = nil) throws {
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
                           period: TimeInterval = TimeInterval(60)) -> CandlesCollection {
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

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()

@available(OSX 10.11, *)
extension DukascopyProvider {
    private
    func decodeTicks(_ data: Data, range: Range<Date>) throws -> TicksCollection {
        try ticksDecoder.decode(with: data, range: range)
    }

    private
    func decodeTicks(_ fileURL: URL, range: Range<Date>) throws -> TicksCollection {
        let data = try Data(contentsOf: fileURL)

        return try decodeTicks(data, range: range)
    }
}

@available(OSX 10.11, *)
extension DukascopyProvider {
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
