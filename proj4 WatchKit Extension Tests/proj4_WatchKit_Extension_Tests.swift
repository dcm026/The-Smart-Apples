//
//  proj4_WatchKit_Extension_Tests.swift
//  proj4 WatchKit Extension Tests
//
//  Created by Katie Till on 2/23/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import XCTest
@testable import proj4

class proj4_WatchKit_Extension_Tests: XCTestCase {
    var sut: Data
    

    override func setUpWithError() throws {
        let testval = 555
        super.setUp()
        sut = Data(from: testval)
        let status = KeyChain.save(key: "MyNumber", sut: sut)
        let receivedData = KeyChain.load(key:  "MyNumber")
        let result = receivedData.to(type: Int.self)
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testKeyChain(){
        XCTAssertEqual(result, 555, "Mismatch Results")
        
    }

}
