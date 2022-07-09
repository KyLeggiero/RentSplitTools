//
//  Measurement + UnitDuration + conveniences.swift
//  
//
//  Created by S🌟System on 2022-07-09.
//

import Foundation



internal extension Measurement where UnitType == UnitDuration {
    
    /// An approximation of a month: one-twelfth of a mean tropical year
    static var month: Self { .init(value: 1/12, unit: .years) }
}



internal extension UnitDuration {
    
    /// Mean tropical years (as measured in the year 2000: 31,556,925.216 seconds)
    static let years = UnitDuration(symbol: "y", converter: UnitConverterLinear(coefficient: 365.24219 * 24 * 60 * 60))
}
