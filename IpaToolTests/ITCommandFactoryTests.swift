//
//  ITCommandFactoryTests.swift
//  IpaTool
//
//  Created by Stefan on 04/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import UIKit
import XCTest

class ITCommandFactoryTests: XCTestCase {

    func testFactoryHasCommands()
    {
        let factory = ITCommandFactory()
        let commands : Dictionary<String, ITCommand> = factory.commands
        XCTAssertNotEqual(commands.count, 0)
    }
}
