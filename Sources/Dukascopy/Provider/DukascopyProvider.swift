//
//  DukascopyProvider.swift
//  Chart
//
//  Created by Vitali Kurlovich on 3/12/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@available(OSX 10.11, *)
class DukascopyProvider {
    enum ProviderError: Swift.Error {
        case invalidData
    }

    private let urlFactory = DukascopyURLFactory()

    private let downloader = DukascopyDownloader()

    private let decoder = Decoder()
}

@available(OSX 10.11, *)
extension DukascopyProvider {
    typealias TaskResult = Result<TicksCollection, Error>

    func fetch(for currency: String, range: Range<Date>, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(for: currency, range: range) { result in
            switch result {
            case let .success(result):

                var ticks: TicksCollection?

                for item in result {
                    switch item {
                    case let .success(duka):
                        do {
                            let chunk = try self.decode(duka.data, date: duka.time)

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
                        // chunks.append(.failure(error))
                    }
                }

                completion?(.success(ticks!))

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    func fetch(for currency: String, date: Date, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        try fetch(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!, completion: completion)
    }

    func fetch(for currency: String, year: Int, month: Int, day: Int, hour: Int, completion: ((Result<TicksCollection, Error>) -> Void)? = nil) throws {
        try downloader.download(for: currency, year: year, month: month, day: day, hour: hour) { result in
            switch result {
            case let .success((data, time)):
                do {
                    let chunks = try self.decode(data, date: time)
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

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()

@available(OSX 10.11, *)
extension DukascopyProvider {
    private
    func decode(_ data: Data, date: Date) throws -> TicksCollection {
        try decoder.decode(with: data, start: date)
    }

    private
    func decode(_ fileURL: URL, date: Date) throws -> TicksCollection {
        let data = try Data(contentsOf: fileURL)

        return try decode(data, date: date)
    }
}
