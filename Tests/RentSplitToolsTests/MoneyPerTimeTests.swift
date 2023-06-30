//
//  MoneyPerTimeTests.swift
//  
//
//  Created by The Northstar✨ System on 10/27/22.
//

import XCTest
import RentSplitTools



final class MoneyPerTimeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTimeConversion() throws {
        let yearly_12000 = MoneyPerTime(money: 12_000, per: .year)
        XCTAssertEqual(yearly_12000.money, 12_000, accuracy: 0.0001)
        XCTAssertEqual(yearly_12000.monthly.money, 1_000, accuracy: 0.0001)
        XCTAssertEqual(yearly_12000.money, 12_000, accuracy: 0.0001)
        
        var converted = yearly_12000
        converted.time = .day
        XCTAssertEqual(converted.money, 32.8549120595, accuracy: 0.000001) // 12_000 / 365.242189)
    }
}
