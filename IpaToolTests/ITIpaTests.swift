//
//  ITIpaTests.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import XCTest

class ITIpaTests_testConfig: XCTestCase {

    var config = ITTestConfig()
    var tempDirUrl:NSURL!
    
    override func setUp() {
        config.load()
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
        XCTAssertNotNil(config.ipaPath)
    }

    func testExtractIpa()
    {
        let ok = SSZipArchive.unzipFileAtPath(config.ipaFullPath!, toDestination: tempDirUrl?.path!)
        XCTAssertTrue(ok)
    }
    
}

class ITIpaTests: XCTestCase
{
    var config = ITTestConfig()
    var tempDirUrl:NSURL!
    var ipa:ITIpa!

    override func setUp() {
        config.load()
        tempDirUrl = ITIpa.createTempDir()

        ipa = ITIpa()
        let ipaPath = config.ipaPath
        let bundle = NSBundle(forClass: self.dynamicType)
        let ipaFullPath = bundle.pathForResource(ipaPath.stringByDeletingPathExtension, ofType:"ipa")
        let (ok, error) = ipa.load(ipaFullPath!)
        XCTAssertTrue(ok)
    }
    
    override func tearDown() {
        var error:NSError?
        NSFileManager.defaultManager().removeItemAtURL(tempDirUrl, error: &error)
    }

    func testAppName()
    {
        XCTAssertEqual(config.appName, ipa.appName)
    }
    
    func testDisplayName()
    {
        XCTAssertEqual(config.displayName, ipa.displayName)
    }
    
    func testBundleShortVersionString()
    {
        XCTAssertEqual(config.bundleShortVersionString, ipa.bundleShortVersionString)
    }
    
    func testBundleVersion()
    {
        XCTAssertEqual(config.bundleVersion, ipa.bundleVersion)
    }
    
    func testBundleIdentifier()
    {
        XCTAssertEqual(config.bundleIdentifier, ipa.bundleIdentifier)
    }
    
    func testMinimumOSVersion()
    {
        XCTAssertEqual(config.minimumOSVersion, ipa.minimumOSVersion)
    }
    
    func testReadProvisioningInformation()
    {
        // TODO This file is created using 'security cms -D -i embedded.mobileprovision -o prov.plist'. The required APIs are not available on iOS, and I don't have 10.10 SDK yet
        let bundle = NSBundle(forClass: self.dynamicType)
        let provPlistPath = bundle.pathForResource("prov", ofType: "plist")
        var provPlist = NSDictionary(contentsOfFile: provPlistPath!)
        
        var certificates = provPlist!["DeveloperCertificates"]! as [NSData]
        var certificate = certificates[0]
        var decodedCertificate:SecCertificate = SecCertificateCreateWithData(nil, certificate).takeUnretainedValue()
        var summary:String = String(SecCertificateCopySubjectSummary(decodedCertificate).takeUnretainedValue())
        XCTAssertEqual(config.codeSigningAuthority, summary)
        XCTAssertEqual(config.provisioningExpiration!, provPlist!["ExpirationDate"]! as NSDate)
        XCTAssertEqual(config.provisioningName, provPlist!["Name"] as String)
        XCTAssertEqual(config.provisioningAppIdName, provPlist!["AppIDName"] as String)
        XCTAssertEqual(config.provisioningTeam, provPlist!["TeamName"] as String)
    }
    
    func testCodeSigningAuthority()
    {
        XCTAssertEqual(config.codeSigningAuthority, ipa.codeSigningAuthority)
    }
}
