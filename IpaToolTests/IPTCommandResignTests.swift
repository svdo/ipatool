//
//  IPTCommandResignTests.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class IPTCommandResignTests: XCTestCase {

    var config = ITTestConfig()
    var resignCommand = IPTCommandResign()
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
    }
    
    func testReturnsExpectedOutput()
    {
        let app = config.appName + ".ipa"
        let bundleId = config.bundleIdentifier
        let expectedPath = config.ipaFullPath?.stringByDeletingLastPathComponent.stringByAppendingPathComponent("\(config.appName)_resigned.ipa")
        let expectedOutputFirstLine = "\(app): replacing existing signature"
        let expectedOutputLastLine = "Resigned ipa: \(expectedPath)"
        
        let result = resignCommand.execute([config.ipaFullPath!])
        let lines = result.componentsSeparatedByString("\n")
        XCTAssertEqual(lines[0], expectedOutputFirstLine)
        XCTAssertEqual(lines[lines.count-1], expectedOutputLastLine)
    }

}
