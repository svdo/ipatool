//
//  ITIpaTests.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import UIKit
import XCTest

class ITIpaTests_testConfig: XCTestCase {

    var config:AnyObject?
    var tempDirUrl:NSURL!
    
    override func setUp() {
        config = ITIpaTests_testConfig.loadConfig()
        tempDirUrl = ITIpa.createTempDir()
    }
    
    override func tearDown() {
        var error:NSError?
        NSFileManager.defaultManager().removeItemAtURL(tempDirUrl, error: &error)
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

    class func loadConfig() -> AnyObject? {
        let bundle = NSBundle(forClass: self)
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
        let ok = SSZipArchive.unzipFileAtPath(ipaPath, toDestination: tempDirUrl?.path!)
        XCTAssertTrue(ok)
    }
    
}

class ITIpaTests: XCTestCase
{
    var config:AnyObject?
    var tempDirUrl:NSURL!
    var ipa:ITIpa!

    override func setUp() {
        config = ITIpaTests_testConfig.loadConfig()
        tempDirUrl = ITIpa.createTempDir()

        ipa = ITIpa()
        let ipaPath = config!["ipaPath"] as String
        let (ok, error) = ipa.load(ipaPath)
        XCTAssertTrue(ok)
    }
    
    override func tearDown() {
        var error:NSError?
        NSFileManager.defaultManager().removeItemAtURL(tempDirUrl, error: &error)
    }

    func testAppName()
    {
        XCTAssertEqual(config!["appName"] as String, ipa.appName)
    }
    
    func testDisplayName()
    {
        XCTAssertEqual(config!["displayName"] as String, ipa.displayName)
    }
    
    func testBundleShortVersionString()
    {
        XCTAssertEqual(config!["bundleShortVersionString"] as String, ipa.bundleShortVersionString)
    }
    
    func testBundleVersion()
    {
        XCTAssertEqual(config!["bundleVersion"] as String, ipa.bundleVersion)
    }
    
    func testBundleIdentifier()
    {
        XCTAssertEqual(config!["bundleIdentifier"] as String, ipa.bundleIdentifier)
    }
    
    func testMinimumOSVersion()
    {
        XCTAssertEqual(config!["minimumOSVersion"] as String, ipa.minimumOSVersion)
    }
    
    func testReadProvisioningInformation()
    {
        // TODO This file is created using 'security cms -D -i embedded.mobileprovision -o prov.plist'. The required APIs are not available on iOS, and I don't have 10.10 SDK yet
        var provPlist = NSDictionary(contentsOfFile: "/Users/stefan/Desktop/xx/Payload/Blaat.app/prov.plist")
        
        var certificates = provPlist["DeveloperCertificates"]! as [NSData]
        var certificate = certificates[0]
        var decodedCertificate:SecCertificate = SecCertificateCreateWithData(nil, certificate).takeUnretainedValue()
        var summary:String = String(SecCertificateCopySubjectSummary(decodedCertificate).takeUnretainedValue())
        XCTAssertEqual(config!["codeSigningAuthority"] as String, summary)
        
        XCTAssertEqual(config!["provisioningName"] as String, provPlist["Name"] as String)
        
        var df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        var expectedDate = df.dateFromString(config!["provisioningExpiration"] as String)
        XCTAssertEqual(expectedDate!, provPlist["ExpirationDate"]! as NSDate)
        
        XCTAssertEqual(config!["provisioningAppIdName"] as String, provPlist["AppIDName"] as String)
    }
}
