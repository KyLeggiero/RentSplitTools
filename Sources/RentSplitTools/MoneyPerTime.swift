//
//  MoneyPerTime.swift
//  
//
//  Created by S🌟System on 2022-07-08.
//

import CoreGraphics
import Foundation



/// Some amouont of money which occurs once every certain amount of time, such as $10/mo or $99/yr
public struct MoneyPerTime {
    
    /// How much money there is each repetition
    public var money: Money
    
    /// How much time between repetitions
    public var time: Time
    
    
    init(money: Money, per time: Time) {
        self.money = money
        self.time = time
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



// MARK: - Conformances

extension MoneyPerTime: Hashable {}
