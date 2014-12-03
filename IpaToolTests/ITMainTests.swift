//
//  IpaToolTests.swift
//  IpaToolTests
//
//  Created by Stefan on 01/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

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
        let output = ipaTool.run([])
        let range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
    
    func testShowsUsageWithInvalidParameters()
    {
        let output = ipaTool.run(["some_ipa", "invalid_parameter"])
        let range = output.lowercaseString.rangeOfString("usage")
        XCTAssertTrue(range != nil)
    }
    
    func testInfoCommand()
    {
        let command:ITCommand? = ipaTool.commandForArguments(["some.ipa", "info"])
        XCTAssertNotNil(command)
        XCTAssertTrue(command is ITCommandInfo)
    }
    
    func testVersionCommand()
    {
        let command:ITCommand? = ipaTool.commandForArguments(["some.ipa", "version"])
        XCTAssertNotNil(command)
        XCTAssertTrue(command is IPTCommandVersion)
    }

    func testBuildCommand()
    {
        let command:ITCommand? = ipaTool.commandForArguments(["some.ipa", "build"])
        XCTAssertNotNil(command)
        XCTAssertTrue(command is IPTCommandBuild)
    }
    
    func testResignCommand()
    {
        let command:ITCommand? = ipaTool.commandForArguments(["some.ipa", "resign"])
        XCTAssertNotNil(command)
        XCTAssertTrue(command is IPTCommandResign)
    }

    func testDefaultCommandIsInfo()
    {
        let command:ITCommand? = ipaTool.commandForArguments(["some.ipa"])
        XCTAssertNotNil(command)
        XCTAssertTrue(command is ITCommandInfo)
    }
}
