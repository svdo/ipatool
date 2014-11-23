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

    var config = ITTestConfig()
    var infoCommand = ITCommandInfo()
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        infoCommand = ITCommandInfo()
    }
    
    func testReturnsErrorWithInvalidIpa() {
        let result = infoCommand.execute(["bla"])
        let range = result.rangeOfString("error", options:NSStringCompareOptions.CaseInsensitiveSearch)
        XCTAssertFalse(range == nil)
    }
    
    func testReturnsNoErrorWithValidIpa() {
        let result = infoCommand.execute([config.ipaFullPath!])
        let range = result.rangeOfString("error", options:NSStringCompareOptions.CaseInsensitiveSearch)
        XCTAssertTrue(range == nil)
    }
    
    func testReturnsInfoWithValidIpa() {
        
        let expectedOutput = "  App name:            Blaat.app\n" +
            "  Display name:        Bèèèh!\n" +
            "  Version:             1.0\n" +
            "  Build:               1\n" +
            "  Bundle identifier:   com.vandenoord.Blaat\n" +
            "  Code sign authority: iPhone Distribution: Stefan van den Oord (7EQ9KX3BR9)\n" +
            "  Minimum OS version:  8.0\n" +
            "  Device family:       iphone\n" +
            "\n" +
            "Provisioning:\n" +
            "  Name:                Blaat ad hoc\n" +
            "  Expiration:          Wed Apr 15 17:48:44 CET 2015\n" +
            "  App ID name:         Blaat\n" +
            "  Team:                Stefan van den Oord\n";
        let result = infoCommand.execute([config.ipaFullPath!])
        XCTAssertEqual(expectedOutput, result)
    }
}
