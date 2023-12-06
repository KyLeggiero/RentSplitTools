//
//  MoneyPerTime.swift
//  
//
//  Created by The Northstar✨ System on 2022-07-08.
//

import CoreGraphics
import Foundation

import BasicMathTools
import MultiplicativeArithmetic



///// Some amouont of money which occurs once every certain amount of time, such as $10/mo or $99/yr
public struct MoneyPerTime {
    
    /// How much money there is each repetition
    public var money: Money
    
    /// How much time between repetitions
    public var time: Time { didSet { convertMoney(from: oldValue, to: time) } }
    
    
    public init(money: Money, per time: Time) {
        self.money = money
        self.time = time
    }
    
    
    public init(money: Money, per timeUnit: UnitDuration) {
        self.money = money
        self.time = .init(value: 1, unit: timeUnit)
    }
}



public extension MoneyPerTime {
    typealias Money = CGFloat
    typealias Time = Measurement<UnitDuration>
}



public extension MoneyPerTime.Money {
    func per(_ time: MoneyPerTime.Time) -> MoneyPerTime {
        .init(money: self, per: time)
    }
    
    
    @inline(__always)
    static func / (lhs: Self, rhs: MoneyPerTime.Time) -> MoneyPerTime {
        lhs.per(rhs)
    }
}



public extension MoneyPerTime {
    var monthly: Self {
        var copy = self
        copy.time = .month
        return copy
    }
}



// MARK: - Internal implementations

private extension MoneyPerTime {
    mutating func convertMoney(from oldTime: Time, to newTime: Time) {
        guard oldTime != newTime else { return }
        let oldSeconds = oldTime.converted(to: .seconds).value
        let newSeconds = newTime.converted(to: .seconds).value
        let ratePerSecond = money / oldSeconds
        money = ratePerSecond * newSeconds
    }
}



// MARK: - Conformances

extension MoneyPerTime: Codable {}
extension MoneyPerTime: Hashable {}



extension MoneyPerTime: CustomStringConvertible {
    
    public var description: String {
        FloatingPointFormatStyle
            .Currency(code: "USD")
            .format(money)
        + "/"
        + timeDescription
    }
    
    
    private var timeDescription: String {
        time.unit.symbol
    }
}



// MARK: - Private conveniences

private extension MoneyPerTime {
    static func apply(
        _ operator: (Money, Money) -> Money,
        to operands: (lhs: MoneyPerTime,
                      rhs: MoneyPerTime))
    -> MoneyPerTime {
        MoneyPerTime(money: `operator`(operands.lhs.monthly.money, operands.rhs.monthly.money), per: .months)
    }
    
    
    static func apply(
        _ operator: (Money) -> Money,
        to operand: MoneyPerTime)
    -> MoneyPerTime {
        MoneyPerTime(money: `operator`(operand.monthly.money), per: .months)
    }
    
    
    static func apply(
        _ operator: (Money, Money) -> Money,
        to operands: (lhs: MoneyPerTime,
                      rhs: Money))
    -> MoneyPerTime {
        MoneyPerTime(money: `operator`(operands.lhs.monthly.money, operands.rhs), per: .months)
    }
}



// MARK: AdditiveArithmetic

extension MoneyPerTime: AdditiveArithmetic {
    public static func + (lhs: MoneyPerTime, rhs: MoneyPerTime) -> MoneyPerTime {
        apply(+, to: (lhs, rhs))
    }
    
    
    public static func - (lhs: MoneyPerTime, rhs: MoneyPerTime) -> MoneyPerTime {
        apply(-, to: (lhs, rhs))
    }
    
    
    public static var zero: Self {  0 / .month }
}


// MARK: - MultiplicativeArithmetic

extension MoneyPerTime: SimpleMultiplicativeArithmetic {
    
    public func pow(_ exponent: MoneyPerTime) -> MoneyPerTime {
        Self.apply(CoreGraphics.pow, to: (lhs: self, rhs: exponent))
    }
    
    
    public func pow(_ exponent: Money) -> MoneyPerTime {
        Self.apply(CoreGraphics.pow, to: (lhs: self, rhs: exponent))
    }
    
    
    public func sqrt() -> MoneyPerTime {
        Self.apply(CoreGraphics.sqrt, to: self)
    }
    
    
    public static func * (lhs: MoneyPerTime, rhs: MoneyPerTime) -> MoneyPerTime {
        apply(*, to: (lhs, rhs))
    }
    
    
    public static func * (lhs: MoneyPerTime, rhs: Money) -> MoneyPerTime {
        apply(*, to: (lhs, rhs))
    }
    
    
    public static func / (lhs: MoneyPerTime, rhs: MoneyPerTime) -> MoneyPerTime {
        apply(/, to: (lhs, rhs))
    }
    
    
    public static func / (lhs: MoneyPerTime, rhs: Money) -> MoneyPerTime {
        apply(/, to: (lhs, rhs))
    }
}
