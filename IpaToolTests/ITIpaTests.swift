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

    var config:AnyObject?
    var tempDirUrl:NSURL?
    
    override func setUp() {
        config = loadConfig()
        tempDirUrl = createTempDir()
    }
    
    override func tearDown() {
        var error:NSError?
        NSFileManager.defaultManager().removeItemAtURL(tempDirUrl!, error: &error)
    }
    
    func testLoad()
    {
        let ipa = ITIpa()
        let (ok, error) = ipa.load("nonexisting.ipa")
        XCTAssertFalse(ok)
    }

    func testLoadTestConfig()
    {
        let ipaPath = config!["ipaPath"] as String
        XCTAssertNotNil(ipaPath)
    }

    func loadConfig() -> AnyObject? {
        let bundle = NSBundle(forClass: self.dynamicType)
        let configFilePath:String? = bundle.pathForResource("testConfig", ofType: "json")
        XCTAssertNotNil(configFilePath)
        
        var error:NSError?
        let jsonData = NSData.dataWithContentsOfFile(configFilePath!, options:NSDataReadingOptions(0), error: &error)
        XCTAssertNotNil(jsonData)
        let config: AnyObject? = NSJSONSerialization.JSONObjectWithData(jsonData, options:NSJSONReadingOptions(0), error:&error)
        XCTAssertNotNil(config)

        return config
    }
    
    func testExtractIpa()
    {
        let ipaPath = config!["ipaPath"] as String
        

        
    }
    
    func createTempDir() -> NSURL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let tempDirPath = systemTempDir.stringByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
        println("tempDirUrl = \(tempDirUrl!)")
        
        var error:NSError?
        let created = NSFileManager.defaultManager().createDirectoryAtURL(tempDirUrl!, withIntermediateDirectories: true, attributes: nil, error: &error)
        XCTAssertTrue(created)
        
        return tempDirUrl
    }
}


