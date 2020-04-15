//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 4/14/20.
//

import Foundation

internal
struct DukascopyTick: Equatable {
    let time: Int32
    let askp: Int32
    let bidp: Int32
    let askv: Float32
    let bidv: Float32
}
