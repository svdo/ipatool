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
        XCTAssertTrue(ok)
        
        let exitCode = cmd.exitCode
        XCTAssertEqual(Int32(1), exitCode)
    }

    func testCanExecuteCommandWithArgument()
    {
        let tempDir = NSTemporaryDirectory()
        let tempFile = NSUUID().UUIDString
        let tempPath = tempDir.stringByAppendingPathComponent(tempFile)
        XCTAssertFalse(NSFileManager.defaultManager().isReadableFileAtPath(tempPath))
        
        let ok = cmd.execute("/usr/bin/touch", [tempPath])
        
        XCTAssertTrue(ok)
        
        let exitCode = cmd.exitCode
        XCTAssertEqual(Int32(0), exitCode)
        
        XCTAssertTrue(NSFileManager.defaultManager().isReadableFileAtPath(tempPath))
        NSFileManager.defaultManager().removeItemAtPath(tempPath, error: nil)
    }
    
    func testCanReadStandardOutput()
    {
        cmd.execute("/bin/echo", ["test1", "test2", "test3"])
        XCTAssertNotNil(cmd.standardOutput)
        XCTAssertEqual("test1 test2 test3\n", cmd.standardOutput!)
    }
}
