//
//  ITIpaTests.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import UIKit
import XCTest

class ITIpaTests: XCTestCase {

    func testLoad()
    {
        let ipa = ITIpa()
        let (ok, error) = ipa.load("nonexisting.ipa")
        XCTAssertFalse(ok)
    }

}
