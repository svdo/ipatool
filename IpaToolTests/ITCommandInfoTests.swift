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
        let range = result.range(of: "error", options:NSString.CompareOptions.caseInsensitive)
        XCTAssertFalse(range == nil)
    }
    
    func testReturnsNoErrorWithValidIpa() {
        let result = infoCommand.execute([config.ipaFullPath!])
        let range = result.range(of: "error", options:NSString.CompareOptions.caseInsensitive)
        XCTAssertTrue(range == nil)
    }
    
    func testReturnsInfoWithValidIpa() {
        let line1 = "  App name:            \(config.appName)\n"
        let line2 = "  Display name:        \(config.displayName)\n"
        let line3 = "  Version:             \(config.bundleShortVersionString)\n"
        let line4 = "  Build:               \(config.bundleVersion)\n"
        let line5 = "  Bundle identifier:   \(config.bundleIdentifier)\n"
        let line6 = "  Code sign authority: \(config.codeSigningAuthority)\n"
        let line7 = "  Minimum OS version:  \(config.minimumOSVersion)\n"
        let line8 = "  Device family:       \(config.deviceFamily)\n"
        let line9 = "\n"
        let line10 = "Provisioning:\n"
        let line11 = "  Name:                \(config.provisioningName)\n"
        let line12 = "  Expiration:          \(infoCommand.formatDate(config.provisioningExpiration! as Date))\n"
        let line13 = "  App ID name:         \(config.provisioningAppIdName)\n"
        let line14 = "  Team:                \(config.provisioningTeam)\n"
        let expectedOutput = line1+line2+line3+line4+line5+line6+line7+line8+line9+line10+line11+line12+line13+line14
        let result = infoCommand.execute([config.ipaFullPath!])
        XCTAssertEqual(expectedOutput, result)
    }
}
