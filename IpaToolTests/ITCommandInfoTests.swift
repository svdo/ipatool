//
//  ITCommandInfoTests.swift
//  ipatool
//
//  Created by Stefan on 15/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class ITCommandInfoTests: XCTestCase {

    func testInfoReturnsErrorWithInvalidIpa() {
        let infoCommand = ITCommandInfo()
        let result = infoCommand.execute(["bla"])
        let range = result.rangeOfString("error")
        XCTAssertTrue(range == nil)
    }
}
