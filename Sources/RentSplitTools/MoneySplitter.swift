//
//  MoneySplitter.swift
//  
//
//  Created by The Northstar✨ System on 2022-07-07.
//

import CoreGraphics
import Foundation

import AppUniqueIdentifier
import SimpleLogging



/// Performs the heavy-lifting of splitting money across people
public struct MoneySplitter {
    
    /// Everyone participating in this split
    public var people: [Person] {
        didSet {
            recalculateSplit()
        }
    }
    
    /// All the people participating in this split who live in the home and pay expenses
    public var roommates: [Roommate] {
        didSet {
            recalculateSplit()
        }
    }
    
    /// All the people are participating in this split who give money to others in this split
    public var benefactors: [Benefactor] {
        didSet {
            recalculateSplit()
        }
    }
    
    /// All the expenses that the roommates split. Defaults to a reasonable example
    public var expenses: [Expense] {
        didSet {
            recalculateSplit()
        }
    }
    
    public fileprivate(set) var split = Split(shares: [])
    
    
    public init(
        people: [Person] = .default,
        roommates: [Roommate],
        benefactors: [Benefactor] = .default,
        expenses: [Expense])
    {
        self.people = people
        self.roommates = roommates
        self.benefactors = benefactors
        self.expenses = expenses
        
        self.recalculateSplit()
    }
    
    
    public init(
        people: [Person] = .default,
        roommates: [Roommate],
        benefactors: [Benefactor] = .default)
    {
        self.init(people: people,
                  roommates: roommates,
                  benefactors: benefactors,
                  expenses: .default(for: people))
    }
    
    
    public init(
        people: [Person] = .default,
        benefactors: [Benefactor] = .default,
        expenses: [Expense])
    {
        self.init(
            people: people,
            roommates: .default(for: people),
            benefactors: benefactors,
            expenses: expenses
        )
    }
    
    
    public init(
        people: [Person] = .default,
        benefactors: [Benefactor] = .default)
    {
        self.init(
            people: people,
            roommates: .default(for: people),
            benefactors: benefactors,
            expenses: .default(for: people)
        )
    }
}



// MARK: - Functionality

public extension MoneySplitter {
    
    // MARK: Expenses
    
    func get<Field>(_ field: KeyPath<Expense, Field>, of expense: Expense) -> Field? {
        expenses.get(field, ofElementWithId: expense.id)
    }
    
    
    mutating func set<Field>(_ field: WritableKeyPath<Expense, Field>, of expense: Expense, to newValue: Field) {
        self.mutate(expenseWithId: expense.id) { expense in
            expense[keyPath: field] = newValue
        }
    }
    
    var expensesTotal: MoneyPerTime.Money {
        expenses
            .map(\.rate.monthly.money)
            .reduce(into: 0, +=)
    }
    
    
    // MARK: People
    
    func get<Field, MetaPerson: PersonMetadata>(_ field: KeyPath<Person, Field>, of person: MetaPerson) -> Field? {
        people.get(field, ofElementWithId: person.id)
    }
    
    
    func get<Field>(_ field: KeyPath<Person, Field>, of person: Person) -> Field? {
        people.get(field, ofElementWithId: person.id)
    }
    
    
    mutating func set<Field, MetaPerson: PersonMetadata>(_ field: WritableKeyPath<Person, Field>, of person: MetaPerson, to newValue: Field) {
        people.set(field, ofElementWithId: person.id, to: newValue)
    }
    
    
    mutating func set<Field>(_ field: WritableKeyPath<Person, Field>, of person: Person, to newValue: Field) {
        people.set(field, ofElementWithId: person.id, to: newValue)
    }
    
    
    mutating func set<Field>(_ field: WritableKeyPath<Roommate, Field>, ofRoommateWithId personId: Person.ID, to newValue: Field) {
        roommates.set(field, ofElementWithId: personId, to: newValue)
    }
    
    
    mutating func set<Field>(_ field: WritableKeyPath<Benefactor, Field>, ofBenefactorWithId personId: Person.ID, to newValue: Field) {
        benefactors.set(field, ofElementWithId: personId, to: newValue)
    }
    
    
    func getOrGenerateName<MetaPerson: PersonMetadata>(of person: MetaPerson) -> String {
        get(\.name, of: person)
            ?? Person.generateName(with: person.id)
    }
}



private extension MoneySplitter {
    
    /// Mutates the expense which has the given expense ID.
    ///
    /// If no such expense is found, no action is taken
    ///
    /// - Parameters:
    ///   - expenseId: The ID of an expense in this money splitter
    ///   - mutator:   The function which will mutate the expense
    /// - Returns: The new value after mutation, or `nil` if no such expense exists
    @discardableResult
    mutating func mutate(expenseWithId expenseId: Expense.ID, by mutator: (inout Expense) -> Void) -> Expense? {
        expenses.mutate(elementWithId: expenseId, by: mutator)
    }
    
    
    /// Mutates the person which has the given ID.
    ///
    /// If no such person is found, no action is taken
    ///
    /// - Parameters:
    ///   - expenseId: The ID of a person in this money splitter
    ///   - mutator:   The function which will mutate the person
    /// - Returns: The new value after mutation, or `nil` if no such person exists
    @discardableResult
    mutating func mutate(PersonWithId personId: Person.ID, by mutator: (inout Person) -> Void) -> Person? {
        people.mutate(elementWithId: personId, by: mutator)
    }
    
    
    mutating func recalculateSplit() {
        
        let benefactorSplits = calculateBenefactorSplits()
        let totalFunds = self.calcualteTotalRoommateFunds(beneficiarySplits: benefactorSplits)
        
        split = .init(shares: self.roommates.map { roomate in
            calculateShare(
                for: roomate,
                beneficiarySplits: benefactorSplits,
                totalIncomes: totalFunds)
        })
    }
    
    
    func roommate(withId id: Person.ID) -> Roommate? {
        roommates.first { $0.id == id }
    }
    
    
    func benefactor(withId id: Person.ID) -> Benefactor? {
        benefactors.first { $0.id == id }
    }
    
    
    func beneficiaries(of benefactor: Benefactor) -> [(Roommate, weight: CGFloat)] {
        roommates.compactMap { roommate in
            switch roommate.funding {
            case .benefactor(id: benefactor.id, weight: let weight):
                return (roommate, weight: weight)
                
            case .benefactor(id: _, weight: _),
                    .income(_):
                return nil
            }
        }
    }
    
    
    func person(withId id: Person.ID) -> Person? {
        people.first { $0.id == id }
    }
    
    
    private func calculateBenefactorSplits() -> BeneficiarySplits {
        benefactors.reduce(into: [:]) { benefactorSplits, benefactor in
            let wholeMonthlyContribution = benefactor.contribution.monthly.money
            let beneficiaries = self.beneficiaries(of: benefactor)
            
            let beneficiaryWeightTotal = beneficiaries.lazy.map(\.weight).sum()
            
            benefactorSplits[benefactor.id] = .init(
                uniqueKeysWithValues:
                    beneficiaries
                    .lazy
                    .map { roommate, weight in
                        return (roommateId: roommate.id, percent: weight / beneficiaryWeightTotal)
                    }
                    .map { roommateId, percent in
                        (
                            key: roommateId,
                            value: (wholeMonthlyContribution * percent) / .month
                        )
                    }
            )
        }
    }
    
    
    private func calcualteTotalRoommateFunds(beneficiarySplits: BeneficiarySplits) -> MoneyPerTime {
        roommates
            .lazy
            .map { self.fundingSplit(for: $0, beneficiarySplits: beneficiarySplits) }
            .map(\.rate)
            .sum()
    }
    
    
    private func calculateShare(for roommate: Roommate, beneficiarySplits: BeneficiarySplits, totalIncomes: MoneyPerTime) -> Split.RoommateShare {
        
        let funding = fundingSplit(for: roommate, beneficiarySplits: beneficiarySplits)
        let share = funding.rate.monthly.money / totalIncomes.monthly.money
        
        
        guard let roommate = person(withId: roommate.id) else {
            return .init(person: Person(id: roommate.id),
                         funding: funding,
                         expenses: [],
                         benefits: [:])
        }
        
        return .init(
            person: roommate,
            funding: funding,
            expenses: .init(expenses
                .lazy
                .filter { $0.participantIds.contains(roommate.id) }
                .map { expense in
                    .init(originalExpenseId: expense.id,
                          participantId: roommate.id,
                          amountOwed: expense.rate * share)
                }),
            benefits: [Benefactor : MoneyPerTime].init(uniqueKeysWithValues: beneficiarySplits
                .lazy
                .compactMap { (benefactorId, beneficiaries) in self.benefactor(withId: benefactorId).map{($0, beneficiaries)} }
                .compactMap { (benefactor: Benefactor, beneficiaries: [Person.ID : MoneyPerTime]) in
//                    if let beneficiary =
                        (beneficiaries[roommate.id]).map {
                        return (benefactor, $0)
                    }
//                    else {
//                        return nil
//                    }
                }
            )
        )
    }
    
    
    
    private func fundingSplit(for roommate: Roommate, beneficiarySplits: BeneficiarySplits) -> Split.Funding {
        switch roommate.funding {
        case .income(let amount):
            return .income(rate: amount)
            
        case .benefactor(id: let benefactorId, weight: _):
            guard
                let benefactorPerson = person(withId: benefactorId),
                let split = beneficiarySplits[benefactorId]?[roommate.id]
            else {
                return .income(rate: .zero)
            }
            
            return .benefactor(benefactorPerson, rate: split)
        }
    }
    
    
    
    /// A map of each benefactor to all the people they benefit
    private typealias BeneficiarySplits = [Benefactor.ID : [Person.ID : MoneyPerTime]]
}



internal extension MutableCollection where Element: Identifiable {
    
    
    /// Mutates the expense which has the given expense ID.
    ///
    /// If no such expense is found, no action is taken
    ///
    /// - Parameters:
    ///   - expenseId: The ID of an expense in this money splitter
    ///   - mutator:   The function which will mutate the expense
    /// - Returns: The new value after mutation, or `nil` if no such expense exists
    @discardableResult
    mutating func mutate(elementWithId elementId: Element.ID, by mutator: (inout Element) -> Void) -> Element? {
        guard let offset = self
            .enumerated()
            .first(where: { $0.element.id == elementId })?
            .offset
        else {
            log(error: "Attempted to mutate non-existent element with ID \(elementId)")
            return nil
        }
        
        let index = index(startIndex, offsetBy: offset)
        
        mutator(&self[index])
        
        return self[index]
    }
    
    func get<Field>(_ field: KeyPath<Element, Field>, ofElementWithId elementId: Element.ID) -> Field? {
        guard let found = first(where: { $0.id == elementId }) else {
            return nil
        }
        
        return found[keyPath: field]
    }
    
    
    @discardableResult
    mutating func set<Field>(_ field: WritableKeyPath<Element, Field>,
                             ofElementWithId elementId: Element.ID,
                             to newValue: Field)
    -> Element? {
        mutate(elementWithId: elementId) { element in
            element[keyPath: field] = newValue
        }
    }
}



public extension MoneySplitter.Split {
    func share(forPersonWithId id: Person.ID) -> RoommateShare? {
        shares.first { $0.person.id == id }
    }
}



// MARK: - Special types

public extension MoneySplitter {
    
//    /// A mode in which a money splitter can operate
//    enum Mode {
//
//        /// Fairly distribute expenses across rommates who have disparate incomes
//        ///
//        /// For example, if Morgan makes $4,000/mo, and Isi makes $500/mo, this mode will help split up the expenses to Morgan pays 8 times more than Isi for each expense.
//        ///
//        /// In this mode, benefactors are not considered
//        case disparateIncomes
//
//        /// Helps roommates coordinate sharing money when not all rommates have an income, but there are people who are willing to split their income up to share the money across everyone
//        case moneyPooling
//    }
    
    typealias Expense = RentSplitTools.Expense
    
    
    
    /// A person whom is living alongside others, and the person's funding source
    struct Roommate: PersonMetadata, Codable {
        
        /// The ID of the person who is the roommate
        public let id: Person.ID
        
        /// Where the roommate gets their funding to participate in the split
        public var funding: Funding
        
        
        public init(id: Person.ID, funding: Funding) {
            self.id = id
            self.funding = funding
        }
    }
    
    
    
    /// A person who gives someone else monetary assistance
    struct Benefactor: PersonMetadata, Hashable, Codable {
        
        /// The ID of the person who is this benefactor
        public let id: Person.ID
        
        /// How much this benefactor contributes in total
        public var contribution: MoneyPerTime
        
        
        public init(id: Person.ID, contribution: MoneyPerTime) {
            self.id = id
            self.contribution = contribution
        }
    }
    
    
    
    struct Split: Codable {
        public let shares: [RoommateShare]
    }
}



extension MoneySplitter: CustomDebugStringConvertible {
    public var debugDescription: String {
        [
            ["People:"],
            people.map(\.debugDescription),
            ["\nExpenses:"],
            expenses.map(\.debugDescription)
        ]
        .lazy
        .flatMap { $0 }
        .joined(separator: "\n")
    }
}



public protocol PersonMetadata: Identifiable where ID == Person.ID {
}



extension Person: PersonMetadata {}



public extension MoneySplitter.Roommate {
    
    /// Where a rommate gets the funding needed to participate in the split
    enum Funding: Codable {
        
        /// The roommate has an income
        /// - Parameter 0: The amount of money the roommate makes over time. This is used in order to calculate what this roommate's fair share of paying expenses is.
        case income(MoneyPerTime)
        
        /// The roommate has a benefactor who pays for their share of the split
        /// - Parameters:
        ///  - id:     The ID of the benefactor who funds this roommate
        ///  - weight: _optional_ How much of the benefactor's money this person gets. This is not an absolute value of money, but an arbitrary weight. Say all roommates have the same benefactor at a weight of 1, except one roommate who has that same benefactor at a weight of 2. The split will have the benefactor give that person twice as much as they give everyone else.
        case benefactor(id: Person.ID, weight: CGFloat = 1)
    }
}



public extension MoneySplitter.Split {
    
    /// A share of the money split
    struct RoommateShare: Hashable, Identifiable, Codable {
        
        public var id: Person.ID { person.id }
        
        /// The person who shares in the split
        public let person: Person
        
        /// The funding this person receives
        let funding: Funding
        
        /// The expenses taken on by this person
        public let expenses: Set<Expense>
        
        /// The total cost of all expenses
        public let expenseSum: MoneyPerTime
        
        /// The benefits this person gets from their benefactor, if any
        public let benefits: [MoneySplitter.Benefactor : MoneyPerTime]
        
        
        fileprivate init(person: Person,
                         funding: Funding,
                         expenses: Set<Expense>,
                         benefits: [MoneySplitter.Benefactor : MoneyPerTime]) {
            self.person = person
            self.funding = funding
            self.expenses = expenses
            self.benefits = benefits
            
            self.expenseSum = expenses.reduce(into: .zero) { expenseSum, expense in
                expenseSum += expense.amountOwed
            }
        }
    }
    
    
    
    /// An expense is some specific amount of money which is spent every so often for a specific reason by a specific person in a split
    struct Expense: Hashable, Codable {
        
        /// The ID of the expense that this was split from
        public let originalExpenseId: AppUniqueIdentifier
        
        /// The ID of the participant who's paying this expense
        let participantId: AppUniqueIdentifier
        
        /// How much money the participant owes for this expense
        public let amountOwed: MoneyPerTime
    }
    
    
    
    enum Funding: Hashable, Codable {
        case income(rate: MoneyPerTime)
        case benefactor(Person, rate: MoneyPerTime)
        
        var rate: MoneyPerTime {
            switch self {
            case .income(let rate),
                    .benefactor(_, let rate):
                return rate
            }
        }
    }
}



#if DEBUG
extension MoneySplitter.Split.RoommateShare: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        Roommate share \(id): \(person.debugDescription)
        \(funding.debugDescription)
        Expenses:
        \(expenses.sorted(by: \.originalExpenseId))
        """
    }
}



extension MoneySplitter.Split.Funding: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .income(rate: let rate):
            return "income @ \(rate)"
            
        case .benefactor(let person, rate: let rate):
            return "donation from \(person) @ \(rate)"
        }
    }
}
#endif



// MARK: - Default values

public extension Array where Element == MoneySplitter.Roommate {
    static func `default`(for people: [Person]) -> Self {
        people.map { person in
            Element(id: person.id, funding: .income(1200 / .month))
        }
    }
}



public extension Array where Element == Person {
    static var `default`: Self { [
        Element(),
        Element(),
    ] }
}



public extension Array where Element == Expense {
    static func `default`(for people: [Person]) -> Self {
        let participantIds = Set(people.map(\.id))
        return [
            Element(name: "Rent",      rate: 1234.56 / .month, participantIds: participantIds),
            Element(name: "Utilities", rate: 100 / .month, participantIds: participantIds),
        ]
    }
}



public extension Array where Element == MoneySplitter.Benefactor {
    static var `default`: Self { [] }
}



// MARK: - Stringification

public extension MoneySplitter {
    func fundingDescription<PersonInfo: PersonMetadata>(for person: PersonInfo) -> String {
        if let roommate = split.share(forPersonWithId: person.id) {
            return roommate.funding.description
        }
        else if let benefactor = self.benefactor(withId: person.id) {
            return benefactor.contribution.description
        }
        else {
            return "N/A"
        }
    }
}



extension MoneySplitter.Split.Funding: CustomStringConvertible {
    public var description: String {
        switch self {
        case .income(let moneyPerTime):
            return moneyPerTime.description
            
        case .benefactor(let benefactor, rate: let amount):
            return "\(amount) from \(benefactor.name)"
        }
    }
}



// MARK: - Conformance

extension MoneySplitter: Codable {}
