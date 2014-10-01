//
//  IpaToolTests.swift
//  IpaToolTests
//
//  Created by Stefan on 01/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import UIKit
import XCTest

class IpaToolTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testUsage()
    {
        var ipaTool = IpaToolMain()
        var output = ipaTool.run([])
        var range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
}
