//
//  ITCommandFactoryTests.swift
//  IpaTool
//
//  Created by Stefan on 04/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import XCTest

class ITCommandFactoryTests: XCTestCase {

    func testFactoryHasCommands()
    {
        let factory = ITCommandFactory()
        let commands : Dictionary<String, ITCommand> = factory.commands
        XCTAssertEqual(commands.count, 5)
        XCTAssertNotNil(commands["info"])
        XCTAssertNotNil(commands["usage"])
        XCTAssertNotNil(commands["version"])
        XCTAssertNotNil(commands["build"])
        XCTAssertNotNil(commands["resign"])
    }
}
