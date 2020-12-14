//
//  DukascopyDownloader.swift
//  Chart
//
//  Created by Vitali Kurlovich on 4/5/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation
import DukascopyURL
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public
class DukascopyDownloader {
    public typealias Format = URLFactory.Format

    private let urlFactory: URLFactory

    private let cachePolicy: URLRequest.CachePolicy
    private let timeout: TimeInterval

    public init(_ urlFactory: URLFactory = URLFactory(),
                session: URLSession = URLSession(configuration: .default),
                cachePolicy: URLRequest.CachePolicy = .returnCacheDataElseLoad,
                timeout: TimeInterval = TimeInterval(15)) {
        self.cachePolicy = cachePolicy
        self.timeout = timeout

        self.urlFactory = urlFactory
        self.session = session
    }

    private var tasksCache = [URL: URLSessionDataTask]()

    private var tasks = [URLSessionDataTask]()

    private let session: URLSession

    private let utc = TimeZone(identifier: "UTC")!

    private lazy var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utc
        return calendar
    }()

    deinit {
        for (_, task) in tasksCache {
            task.cancel()
        }
    }

    private let dispatchQueue = DispatchQueue(label: "DukascopyDownloader.DispatchQueue")
}

public enum DownloaderError: Swift.Error {
    case invalidData
}

extension DukascopyDownloader {
    public func download(format: Format, for currency: String, range: Range<Date>,
                         dispatchQueue: DispatchQueue = DispatchQueue.main,
                         completion: @escaping ((Result<[Result<(data: Data, range: Range<Date>), Error>], Error>) -> Void)) throws {
        var results = [Result<(data: Data, range: Range<Date>), Error>]()

        let requests = try request(format: format, for: currency, range: range)
        results.reserveCapacity(requests.underestimatedCount)

        let dispatchGroup = DispatchGroup()

        for current in requests {
            let request = current.request
            //let date = current.range

            do {
                dispatchGroup.enter()
                try download(for: request) { result in

                    switch result {
                    case let .success(data):

                        dispatchQueue.async {
                            let range = current.range
                            results.append(.success((data: data, range: range)))
                            dispatchGroup.leave()
                        }

                    case let .failure(error):

                        dispatchQueue.async {
                            results.append(.failure(error))
                            dispatchGroup.leave()
                        }
                    }
                }
            } catch {
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: dispatchQueue) {
            results.sort { (left, right) -> Bool in
                guard let left = try? left.get(),
                    let right = try? right.get() else {
                    return false
                }

                return left.range.lowerBound < right.range.lowerBound
            }

            completion(.success(results))
        }
    }
}

import Logging
private let logger = Logger(label: "Dukascopy.net")

extension DukascopyDownloader {
    public func download(format: Format, for currency: String, date: Date, completion: @escaping ((Result<(data: Data, range: Range<Date>), Error>) -> Void)) throws {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        try download(format: format, for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!, completion: completion)
    }

    public func download(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int = 0, completion: @escaping ((Result<(data: Data, range: Range<Date>), Error>) -> Void)) throws {
        let request = try self.request(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        let components = DateComponents(year: year, month: month, day: day, hour: hour)

        let baseDate = calendar.date(from: components)!

        let range :  Range<Date>
    
        switch format {
       
        default:
            let end = baseDate.addingTimeInterval(60*60) 
            range = baseDate ..< end
        }
        
        try download(for: request) { result in
            switch result {
            case let .success(data):

                let result = (data: data, range: range)

                completion(.success(result))

            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

extension DukascopyDownloader {
    internal
    func downloadInfo(completion: @escaping ((Result<Data, Error>) -> Void)) throws {
        let request = infoRequest()
        try download(for: request, completion: completion)
    }
}

private
extension DukascopyDownloader {
    func download(for request: URLRequest, completion: @escaping ((Result<Data, Error>) -> Void)) throws {
        tasks.forEach { task in
            if task.currentRequest == request {}
        }

        let task = session.dataTask(with: request) { data, _, error in

            defer {
                // self?.tasksCache.removeValue(forKey: requestUrl)
                // tasks.removeAll { $0.currentRequest ==  request}
            }

            if let error = error {
                completion(.failure(error))

            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(DownloaderError.invalidData))
            }
        }

        tasks.append(task)
        task.resume()
    }
}

private
extension DukascopyDownloader {
    func request(format: Format, for currency: String, range: Range<Date>) throws -> [(request: URLRequest, range: Range<Date>)] {
        let urls = try urlFactory.url(format: format, for: currency, range: range)

        return urls.compactMap { (data) -> (request: URLRequest, range: Range<Date>)? in
            let request = URLRequest(url: data.url, cachePolicy: cachePolicy, timeoutInterval: timeout)
            return (request: request, range: data.range)
        }
    }

    func request(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URLRequest {
        let url = try urlFactory.url(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        return URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
    }

    func infoRequest() -> URLRequest {
        let base = "https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json"
        let url = URL(string: base)!

        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)

        request.setValue("freeserv.dukascopy.com", forHTTPHeaderField: "Authority")
        request.setValue("https://freeserv.dukascopy.com/", forHTTPHeaderField: "Referer")

        return request
    }
}
