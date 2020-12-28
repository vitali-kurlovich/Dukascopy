//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 25.12.20.
//

import DukascopyDecoder
import DukascopyDownloader
import DukascopyModel
import Foundation

final class DukascopyTicksProvider {
    private let downloader = DukascopyDownloader()
    private let ticksDecoder = TicksDecoder()
}

@available(OSX 10.11, *)
extension DukascopyTicksProvider {
    func fetch(for currency: String, range: Range<Date>, completion: ((Result<TicksContainer, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .ticks, for: currency, range: range) { result in
            switch result {
            case let .success(result):

                var container: TicksContainer?

                for item in result {
                    switch item {
                    case let .success(duka):
                        do {
                            let ticksContainer = try self.ticksDecoder.decode(in: duka.range, with: duka.data)

                            if container == nil {
                                container = ticksContainer
                            } else {
                                container?.merge(container: ticksContainer)
                                // ticks?.append(chunk)
                            }

                        } catch {
                            completion?(.failure(error))
                        }

                    case let .failure(error):
                        completion?(.failure(error))
                    }
                }

                completion?(.success(container!))

            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

    func fetch(for currency: String, date: Date, completion: ((Result<TicksContainer, Error>) -> Void)? = nil) throws {
        let comps = ProviderCalendar.calendar.dateComponents([.year, .month, .day, .hour], from: date)

        try fetch(for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!, completion: completion)
    }
}

@available(OSX 10.11, *)
private
extension DukascopyTicksProvider {
    func fetch(for currency: String, year: Int, month: Int, day: Int, hour: Int, completion: ((Result<TicksContainer, Error>) -> Void)? = nil) throws {
        try downloader.download(format: .ticks, for: currency, year: year, month: month, day: day, hour: hour) { [weak self] result in
            switch result {
            case let .success((data, range)):
                do {
                    guard let self = self else {
                        return
                    }

                    let container = try self.ticksDecoder.decode(in: range, with: data)

                    completion?(.success(container))
                } catch {
                    completion?(.failure(error))
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }
}
