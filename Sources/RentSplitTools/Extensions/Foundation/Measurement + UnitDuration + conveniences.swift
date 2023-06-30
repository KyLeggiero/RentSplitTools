//
//  Measurement + UnitDuration + conveniences.swift
//  
//
//  Created by The Northstar✨ System on 2022-07-09.
//

import Foundation



public extension Measurement where UnitType == UnitDuration {
    
    /// An approximation of the length of a day in a mean tropical year
    static var day: Self { .init(value: 1, unit: .days) }
    
    /// An approximation of a month: one-twelfth of a mean tropical year
    static var month: Self { .init(value: 1, unit: .months) }
    
    /// A mean tropical year
    static var year: Self { .init(value: 1, unit: .years) }
}



public extension UnitDuration {
    
    /// Mean tropical years (as measured in the year 2000: 31,556,925.216 seconds)
    static let years = UnitDuration(symbol: "y", converter: UnitConverterLinear.years)
    
    /// One-twelfth of a `.year`
    static let months = UnitDuration(symbol: "mo", converter: UnitConverterLinear.months)
    
    /// Mean tropical days (as measured in the year 2000: 31,556,925.216 seconds)
    static let days = UnitDuration(symbol: "d", converter: UnitConverterLinear.days)
}



public extension UnitConverterLinear {
    
    /// Mean tropical years (as measured in the year 2000: 31,556,925.216 seconds)
    static var years: UnitConverterLinear { .init(coefficient: days.coefficient * 365.24219) }
    
    /// One-twelfth of a `.year`
    static var months: UnitConverterLinear { .init(coefficient: years.coefficient / 12) }
    
    /// Ephemeris days (24 hours, each with 60 inutes, each with 60 seconds
    static var days: UnitConverterLinear { .init(coefficient: 24 * 60 * 60) }
}
