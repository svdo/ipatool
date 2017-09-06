//
//  IPTSystemCommandTests.swift
//  ipatool
//
//  Created by Stefan on 01/12/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Cocoa
import XCTest

class IPTSystemCommandTests: XCTestCase {

    var cmd = IPTSystemCommand()
    
    override func setUp() {
        cmd = IPTSystemCommand()
    }
    
    func testCanExecuteCommandAndGetExitCode0()
    {
        let ok = cmd.execute("/usr/bin/true")
        XCTAssertTrue(ok)
        
        let exitCode = cmd.exitCode
        XCTAssertEqual(Int32(0), exitCode)
    }

    func testCanExecuteCommandAndGetExitCode1()
    {
        let ok = cmd.execute("/usr/bin/false")
        XCTAssertFalse(ok)
        
        let exitCode = cmd.exitCode
        XCTAssertEqual(Int32(1), exitCode)
    }

    func testCanExecuteCommandWithArgument()
    {
        let tempDir = NSTemporaryDirectory()
        let tempFile = UUID().uuidString
        let tempPath = (tempDir as NSString).appendingPathComponent(tempFile)
        XCTAssertFalse(FileManager.default.isReadableFile(atPath: tempPath))
        
        let ok = cmd.execute("/usr/bin/touch", [tempPath])
        
        XCTAssertTrue(ok)
        
        let exitCode = cmd.exitCode
        XCTAssertEqual(Int32(0), exitCode)
        
        XCTAssertTrue(FileManager.default.isReadableFile(atPath: tempPath))
        do {
            try FileManager.default.removeItem(atPath: tempPath)
        } catch _ {
        }
    }
    
    func testCanReadStandardOutput()
    {
        _ = cmd.execute("/bin/echo", ["test1", "test2", "test3"])
        XCTAssertNotNil(cmd.standardOutput)
        XCTAssertEqual("test1 test2 test3\n", cmd.standardOutput!)
    }
}
