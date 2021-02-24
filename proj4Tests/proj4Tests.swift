//
//  proj4Tests.swift
//  proj4Tests
//
//  Created by Katie Till on 2/23/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import XCTest
@testable import proj4

class proj4Tests: XCTestCase {

    override func setUpWithError() throws {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testKeys() throws {
        let testval = 555
        let sut = Data(from: testval)
        let status = KeyChain.save(key: "MyNumber", data: sut)
        let receivedData = KeyChain.load(key:  "MyNumber")
        let result = receivedData!.to(type: Int.self)
        XCTAssertEqual(result, 475, "Mismatched key values in keychain test")             // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
