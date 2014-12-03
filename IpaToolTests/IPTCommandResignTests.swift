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
    var output = ""
    var resignedPath = ""
    
    override func setUp() {
        config = ITTestConfig()
        config.load()
        resignCommand = IPTCommandResign()
        resignedPath = IPTCommandResign.resignedPathForPath(config.ipaFullPath!)
        NSFileManager.defaultManager().removeItemAtPath(resignedPath, error:nil)
        output = resignCommand.execute([config.ipaFullPath!, config.resignProvisioningProfilePath, config.resignedBundleIdentifier])
    }
    
    func testReturnsExpectedOutput()
    {
        let bundleId = config.bundleIdentifier
        let appNameWithoutExtension = config.appName.stringByDeletingPathExtension
        let expectedPath:String = config.ipaFullPath!.stringByDeletingLastPathComponent.stringByAppendingPathComponent("\(appNameWithoutExtension)_resigned.ipa")
        let expectedOutputFirstLine = "\(config.appName): replacing existing signature"
        let expectedOutputLastLine = "Resigned ipa: \(expectedPath)"
        
        let lines = output.componentsSeparatedByString("\n")
        XCTAssertEqual(lines[0], expectedOutputFirstLine)
        XCTAssertEqual(lines[lines.count-2], expectedOutputLastLine)
    }
    
    func testCorrectResignFilePath()
    {
        let appNameWithoutExtension = config.appName.stringByDeletingPathExtension
        let expectedPath:String = config.ipaFullPath!.stringByDeletingLastPathComponent.stringByAppendingPathComponent("\(appNameWithoutExtension)_resigned.ipa")
        XCTAssertEqual(resignCommand.resignedPath, expectedPath)
    }
    
    func testResignedIpaExists()
    {
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(resignCommand.resignedPath))
    }

    func testShouldHaveCorrectProvisioningAndCodeSigningAuthorityAndBundleIdentifier()
    {
        let resignedIpa = ITIpa()
        let (success,_) = resignedIpa.load(resignedPath)
        XCTAssertTrue(success)
        XCTAssertEqual(resignedIpa.provisioningProfile!.provisioningName()!, config.resignedProvisioningName)
        XCTAssertEqual(resignedIpa.provisioningProfile!.codeSigningAuthority()!, config.resignedCodeSigningAuthority)
        XCTAssertEqual(resignedIpa.bundleIdentifier, config.resignedBundleIdentifier)
    }
    
    func testCanFindCodesignAllocate()
    {
        let path = resignCommand.codesignAllocate
        XCTAssertNotNil(path)
        XCTAssertEqual("codesign_allocate", path!.lastPathComponent)

        let isExecutable = NSFileManager.defaultManager().isExecutableFileAtPath(path!)
        XCTAssertTrue(isExecutable)
    }
    
    func testValidateArgs_none()
    {
        let (ok,_) = resignCommand.validateArgs([])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_one()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_two()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,"arg2"])
        XCTAssertTrue(ok)
    }

    func testValidateArgs_three()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,"arg2","arg3"])
        XCTAssertTrue(ok)
    }

    func testValidateArgs_four()
    {
        let (ok,_) = resignCommand.validateArgs([config.ipaFullPath!,"arg2","arg3","arg4"])
        XCTAssertFalse(ok)
    }

    func testValidateArgs_invalidWhenFirstIsNotIpa()
    {
        let (ok,_) = resignCommand.validateArgs(["arg1","arg2"])
        XCTAssertFalse(ok)
    }
}

