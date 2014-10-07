//
//  IpaToolTests.swift
//  IpaToolTests
//
//  Created by Stefan on 01/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import UIKit
import XCTest

class ITMainTests: XCTestCase {
    
    var ipaTool : ITMain = ITMain()
    
    override func setUp() {
        ipaTool = ITMain()
    }
    
    func testHasCommandFactory()
    {
        XCTAssertNotNil(ipaTool.commandFactory)
    }
    
    func testShowsUsageWithoutParameters()
    {
        var output = ipaTool.run([])
        var range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
    
    func testShowsUsageWithInvalidParameters()
    {
        var output = ipaTool.run(["invalid_parameter"])
        var range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
    
    func testUsage()
    {
        var output = ipaTool.run(["usage"])
        var range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
    
}
