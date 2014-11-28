//
//  IPTCommandBuildTests.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class IPTCommandBuildTests: XCTestCase {

    var config = ITTestConfig()
    var buildCommand = IPTCommandBuild()
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        buildCommand = IPTCommandBuild()
    }
    
    func testReturnsBuild()
    {
        let result = buildCommand.execute([config.ipaFullPath!])
        XCTAssertEqual(config.bundleVersion, result)
    }

}
