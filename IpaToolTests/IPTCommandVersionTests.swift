//
//  IPTCommandVersionTests.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class IPTCommandVersionTests: XCTestCase {

    var config = ITTestConfig()
    var versionCommand = IPTCommandVersion()
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        versionCommand = IPTCommandVersion()
    }

    func testReturnsVersion()
    {
        let result = versionCommand.execute([config.ipaFullPath!])
        XCTAssertEqual(config.bundleShortVersionString, result)
    }

}
