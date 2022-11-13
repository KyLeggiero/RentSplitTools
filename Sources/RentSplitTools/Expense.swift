//
//  Expense.swift
//  
//
//  Created by S🌟System on 2022-07-08.
//

import Foundation



/// An expense is some specific amount of money which is spent every so often for a specific reason
public struct Expense {
    
    /// Uniquely identifies this expense across the app runtime
    public let id: AppUniqueIdentifier
    
    /// The name of the expense, like `"Utilities"`
    public var name: String
    
    /// How much money this expense costs over time
    public var rate: MoneyPerTime
    
    /// The IDs of everyone who participates in paying for this expense. An empty set represents that everyone contributes
    public var participantIds: Set<Person.ID>
    
    
    /// Creates a new expense
    ///
    /// - Parameters:
    ///   - id:   _optional_ - The ID uniquely identifying this expense across this runtime. Defaults to the next available ID
    ///   - name: The name of the new expense, like `"Internet"`
    ///   - rate: How much money is spent over time for this expense
    ///   - participantIds: _optional_ - The IDs of everyone participating in paying for this expense. An empty set represents everyone contributing. Defaults to an empty set
    public init(
        id: AppUniqueIdentifier = .next(),
        name: String,
        rate: MoneyPerTime,
        participantIds: Set<Person.ID> = [])
    {
        self.id = id
        self.name = name
        self.rate = rate
        self.participantIds = participantIds
    }
}



// MARK: - Conformances

extension Expense: Identifiable {}
extension Expense: Hashable {}



extension Expense: CustomDebugStringConvertible {
    public var debugDescription: String {
        "\(id): \(name) @ \(rate) with participants \(participantIds.sorted())"
    }
}
