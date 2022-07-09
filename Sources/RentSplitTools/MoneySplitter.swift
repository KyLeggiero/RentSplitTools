//
//  MoneySplitter.swift
//  
//
//  Created by S🌟System on 2022-07-07.
//

import Foundation



/// Performs the heavy-lifting of splitting money across people
public struct MoneySplitter {
    
    /// The mode of this money splitter
    fileprivate let mode: Mode
    
    
    public init(mode: Mode) {
        self.mode = mode
    }
}



// MARK: - Mode definitions

public extension MoneySplitter {
    
    /// A mode in which a money splitter can operate
    enum Mode {
        
        /// Fairly distribute expenses across rommates who have disparate incomes
        ///
        /// For example, if Morgan makes $4,000/mo, and Isi makes $500/mo, this mode will help split up the expenses to Morgan pays 8 times more than Isi for each expense
        ///
        /// - Parameters:
        ///   - roommates: _optional_ - All the rommates who are participating in this split. Defaults to a reasonable example
        ///   - expenses:  _optional_ - All the expenses that the roommates split. Defaults to a reasonable example
        case disparateIncomes(roommates: [RoommateWithIncome] = .default, expenses: [Expense] = .default)
        
        /// Helps roommates coordinate sharing money when not all rommates have an income, but there are people who are willing to split their income up to share the money across everyone
        ///
        /// - Parameters:
        ///   - roommates:   _optional_ - All the rommates who are participating in this money pool. Defaults to a reasonable example
        ///   - benefactors: _optional_ - All the benefactors who are helping the roommates by contributing their incomes to the money pool
        ///   - expenses:    _optional_ - All the expenses that the roommates split. Defaults to a reasonable example
        case moneyPooling(roommates: [RoommateWithBenefactor] = .default, benefactors: [Benefactor] = .default, expenses: [Expense] = .default)
        
        /// Fairly distribute expenses across rommates who have disparate incomes
        ///
        /// For example, if Morgan makes $4,000/mo, and Isi makes $500/mo, this mode will help split up the expenses to Morgan pays 8 times more than Isi for each expense
        ///
        /// - Note: This is equivalent to omitting all parameters from the `disparateIncome` enum case
        static var disparateIncomes: Self { .disparateIncomes() }
        
        /// Helps roommates coordinate sharing money when not all rommates have an income, but there are people who are willing to split their income up to share the money across everyone
        ///
        /// - Note: This is equivalent to omitting all parameters from the `moneyPooling` enum case
        static var moneyPooling: Self { .moneyPooling() }
    }
    
    
    
    /// A person whom is living alongside others, and the person's income
    typealias RoommateWithIncome = (roommate: Person, income: MoneyPerTime)
    
    /// A person whom is living alongside others, who is supported by a person who gives them monetary assistance
    typealias RoommateWithBenefactor = (roommate: Person, benefactor: Person.ID)
    
    /// A person who gives someone else monetary assistance
    typealias Benefactor = (benefactor: Person, contribution: MoneyPerTime)
}



// MARK: - Default values

public extension Array where Element == MoneySplitter.RoommateWithIncome {
    static var `default`: Self { [
        Element(roommate: Person(), income: 1200 / .month),
        Element(roommate: Person(), income: 1200 / .month),
    ] }
}



public extension Array where Element == Expense {
    static var `default`: Self { [
        Element(name: "Rent",      rate: 1000 / .month),
        Element(name: "Utilities", rate: 100 / .month),
    ] }
}



public extension Array where Element == MoneySplitter.RoommateWithBenefactor {
    static var `default`: Self {
        let defaultBenefactor = MoneySplitter.defaultBenefactor.benefactor
        
        return [
            Element(roommate: Person(),          benefactor: defaultBenefactor.id),
            Element(roommate: Person(),          benefactor: defaultBenefactor.id),
            Element(roommate: defaultBenefactor, benefactor: defaultBenefactor.id),
        ]
    }
}



public extension Array where Element == MoneySplitter.Benefactor {
    static var `default`: Self { [
        MoneySplitter.defaultBenefactor
    ] }
}



private extension MoneySplitter {
    static let defaultBenefactor = Benefactor(benefactor: Person(), contribution: 2400 / .month)
}
