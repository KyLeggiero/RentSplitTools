import XCTest
@testable import RentSplitTools

final class RentSplitToolsTests: XCTestCase {
    
    let tracy = Person(id: .next(), name: "Tracy Minett")
    let sam = Person(id: .next(), name: "Sam Abrams")
    let alex = Person(id: .next(), name: "Alex Gibbs")
    let isi = Person(id: .next(), name: "Isi Yolotli Mockta")
    let aasha = Person(id: .next(), name: "Aasha Sukarno")
    let aheahe = Person(id: .next(), name: "Ageage Ka'uhane")
    
    
    // MARK: - Simple
    
    func testSimple() throws {
        
        let mortgage  = Expense(
            name: "Mortgage",
            rate: 1000 / .month,
            participantIds: [
                tracy.id,
                isi.id,
            ]
        )
        
        
        let energy = Expense(
            name: "Energy",
            rate: 250 / .month,
            participantIds: [
                tracy.id,
                isi.id,
            ]
        )
        
        
        var moneySplitter = MoneySplitter(
            people: [
                tracy,
                isi,
            ],
            roommates: [
                .init(id: tracy.id, funding: .income(1000 / .month)),
                .init(id: isi.id, funding: .income(1000 / .month)),
            ],
            benefactors: [],
            expenses: [
                mortgage,
                energy,
            ]
        )
        
        let firstSplit = moneySplitter.split
        
        
        XCTAssertEqual(firstSplit.shares.count, 2)
        
        XCTAssertEqual(firstSplit.shares[0].id, tracy.id)
        XCTAssertEqual(firstSplit.shares[0].person, tracy)
        XCTAssertEqual(firstSplit.shares[0].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(firstSplit.shares[0].benefits.count, 0)
        XCTAssertEqual(firstSplit.shares[0].expenseSum, 625 / .month)
        XCTAssertEqual(firstSplit.shares[0].expenses.count, 2)
        for expense in firstSplit.shares[0].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 125 / .month)
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(firstSplit.shares[1].id, isi.id)
        XCTAssertEqual(firstSplit.shares[1].person, isi)
        XCTAssertEqual(firstSplit.shares[1].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(firstSplit.shares[1].benefits.count, 0)
        XCTAssertEqual(firstSplit.shares[1].expenseSum, 625 / .month)
        XCTAssertEqual(firstSplit.shares[1].expenses.count, 2)
        for expense in firstSplit.shares[1].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 125 / .month)
            default:
                XCTFail()
            }
        }
        
        
        moneySplitter.set(\.rate, of: energy, to: 234 / .month)
        
        // Ensure changes are reflected in the split
        
        XCTAssertEqual(moneySplitter.split.shares.count, 2)
        
        XCTAssertEqual(moneySplitter.split.shares[0].id, tracy.id)
        XCTAssertEqual(moneySplitter.split.shares[0].person, tracy)
        XCTAssertEqual(moneySplitter.split.shares[0].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(moneySplitter.split.shares[0].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[0].expenseSum, 617 / .month)
        XCTAssertEqual(moneySplitter.split.shares[0].expenses.count, 2)
        for expense in moneySplitter.split.shares[0].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 117 / .month)
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(moneySplitter.split.shares[1].id, isi.id)
        XCTAssertEqual(moneySplitter.split.shares[1].person, isi)
        XCTAssertEqual(moneySplitter.split.shares[0].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(moneySplitter.split.shares[1].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[1].expenseSum, 617 / .month)
        XCTAssertEqual(moneySplitter.split.shares[1].expenses.count, 2)
        for expense in moneySplitter.split.shares[1].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 117 / .month)
            default:
                XCTFail()
            }
        }
        
        // Ensure change didn't affect old values
        
        XCTAssertEqual(firstSplit.shares.count, 2)
        
        XCTAssertEqual(firstSplit.shares[0].id, tracy.id)
        XCTAssertEqual(firstSplit.shares[0].person, tracy)
        XCTAssertEqual(firstSplit.shares[0].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(firstSplit.shares[0].benefits.count, 0)
        XCTAssertEqual(firstSplit.shares[0].expenseSum, 625 / .month)
        XCTAssertEqual(firstSplit.shares[0].expenses.count, 2)
        for expense in firstSplit.shares[0].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 125 / .month)
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(firstSplit.shares[1].id, isi.id)
        XCTAssertEqual(firstSplit.shares[1].person, isi)
        XCTAssertEqual(firstSplit.shares[1].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(firstSplit.shares[1].benefits.count, 0)
        XCTAssertEqual(firstSplit.shares[1].expenseSum, 625 / .month)
        XCTAssertEqual(firstSplit.shares[1].expenses.count, 2)
        for expense in firstSplit.shares[1].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, 500 / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, 125 / .month)
            default:
                XCTFail()
            }
        }
        
        
        // MARK: Simple roommate mutation
        
        moneySplitter.set(\.funding, ofRoommateWithId: tracy.id, to: .income(1234 / .month))
        
        XCTAssertEqual(moneySplitter.debugDescription, """
        People:
        \(tracy.id): Tracy Minett
        \(isi.id): Isi Yolotli Mockta

        Expenses:
        \(mortgage.id): Mortgage @ $1,000.00/mo with participants [\(tracy.id), \(isi.id)]
        \(energy.id): Energy @ $234.00/mo with participants [\(tracy.id), \(isi.id)]
        """)
        
        // Ensure changes are reflected in the split
        
        XCTAssertEqual(moneySplitter.split.shares.count, 2)
        
        XCTAssertEqual(moneySplitter.split.shares[0].id, tracy.id)
        XCTAssertEqual(moneySplitter.split.shares[0].person, tracy)
        XCTAssertEqual(moneySplitter.split.shares[0].funding, .income(rate: 1234 / .month))
        XCTAssertEqual(moneySplitter.split.shares[0].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[0].expenseSum, ((1234/(1234+1000)) * (1000+234)) / .month)
        XCTAssertEqual(moneySplitter.split.shares[0].expenses.count, 2)
        for expense in moneySplitter.split.shares[0].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, ((1234/(1234+1000)) * (1000)) / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, ((1234/(1234+1000)) * (234)) / .month)
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(moneySplitter.split.shares[1].id, isi.id)
        XCTAssertEqual(moneySplitter.split.shares[1].person, isi)
        XCTAssertEqual(moneySplitter.split.shares[1].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(moneySplitter.split.shares[1].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[1].expenseSum, ((1000/(1234+1000)) * (1000+234)) / .month)
        XCTAssertEqual(moneySplitter.split.shares[1].expenses.count, 2)
        for expense in moneySplitter.split.shares[1].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, ((1000/(1234+1000)) * (1000)) / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, ((1000/(1234+1000)) * (234)) / .month)
            default:
                XCTFail()
            }
        }
        
        
        // MARK: Simple expense mutation
        
        moneySplitter.set(\.rate, of: mortgage, to: 3000 / .month)
        
        XCTAssertEqual(moneySplitter.debugDescription, """
        People:
        \(tracy.id): Tracy Minett
        \(isi.id): Isi Yolotli Mockta

        Expenses:
        \(mortgage.id): Mortgage @ $3,000.00/mo with participants [\(tracy.id), \(isi.id)]
        \(energy.id): Energy @ $234.00/mo with participants [\(tracy.id), \(isi.id)]
        """)
        
        // Ensure changes are reflected in the split
        
        XCTAssertEqual(moneySplitter.split.shares.count, 2)
        
        XCTAssertEqual(moneySplitter.split.shares[0].id, tracy.id)
        XCTAssertEqual(moneySplitter.split.shares[0].person, tracy)
        XCTAssertEqual(moneySplitter.split.shares[0].funding, .income(rate: 1234 / .month))
        XCTAssertEqual(moneySplitter.split.shares[0].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[0].expenseSum, ((1234/(1234+1000)) * (3000+234)) / .month)
        XCTAssertEqual(moneySplitter.split.shares[0].expenses.count, 2)
        for expense in moneySplitter.split.shares[0].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, ((1234/(1234+1000)) * (3000)) / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, ((1234/(1234+1000)) * (234)) / .month)
            default:
                XCTFail()
            }
        }
        
        XCTAssertEqual(moneySplitter.split.shares[1].id, isi.id)
        XCTAssertEqual(moneySplitter.split.shares[1].person, isi)
        XCTAssertEqual(moneySplitter.split.shares[1].funding, .income(rate: 1000 / .month))
        XCTAssertEqual(moneySplitter.split.shares[1].benefits.count, 0)
        XCTAssertEqual(moneySplitter.split.shares[1].expenseSum, ((1000/(1234+1000)) * (3000+234)) / .month)
        XCTAssertEqual(moneySplitter.split.shares[1].expenses.count, 2)
        for expense in moneySplitter.split.shares[1].expenses {
            switch expense.originalExpenseId {
            case mortgage.id:
                XCTAssertEqual(expense.amountOwed, ((1000/(1234+1000)) * (3000)) / .month)
            case energy.id:
                XCTAssertEqual(expense.amountOwed, ((1000/(1234+1000)) * (234)) / .month)
            default:
                XCTFail()
            }
        }
    }
}
