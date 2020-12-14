//
//  TicksSequence.swift
//  Dukascopy
//
//  Created by Vitali Kurlovich on 4/20/20.
//

import Foundation

public protocol TicksSequence: Sequence where Self.Element == Tick {
    var range: Range<Date> { get }
    var bounds: Range<Date> { get }
}
