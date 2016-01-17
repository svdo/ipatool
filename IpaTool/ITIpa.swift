//
//  ITIpa.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation
import SSZipArchive

class ITIpa
{
    var appName = ""
    var appPath = ""
    var extractedIpaPath = ""
    
    var displayName:String? { get {
        return infoPlistContents!["CFBundleDisplayName"] as? String
        } }
    var bundleShortVersionString:String { get { return infoPlistContents!["CFBundleShortVersionString"] as! String } }
    var bundleVersion:String { get { return infoPlistContents!["CFBundleVersion"] as! String } }
    var bundleIdentifier:String { get { return infoPlistContents!["CFBundleIdentifier"] as! String } }
    var minimumOSVersion:String { get { return infoPlistContents!["MinimumOSVersion"] as! String } }
    var deviceFamily:String {
        get {
            var result = ""
            let families:Array<Int> = infoPlistContents!["UIDeviceFamily"] as! Array<Int>
            for f in families {
                switch f as Int {
                    case 1: result += "iphone "
                    case 2: result += "ipad "
                    case 3: result += "appletv "
                default: continue
                }
            }
            return result.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        }
    }
    var provisioningProfile:ITProvisioningProfile? = nil
    private var infoPlistContents:NSDictionary? = nil
    
    deinit
    {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(extractedIpaPath)
        } catch _ {
        }
    }
    
    func load(path:String) -> (result:Bool, error:String!)
    {
        let tempDirUrl = ITIpa.createTempDir()
        extractedIpaPath = tempDirUrl.path!

        if !NSFileManager.defaultManager().isReadableFileAtPath(path) {
            return (false, "File not found: \(path)")
        }
        
        let ok = SSZipArchive.unzipFileAtPath(path, toDestination: extractedIpaPath)
        if !ok {
            return (false, "Failed to extract \(path)")
        }
        
        extractAppName(extractedIpaPath)
        extractInfoPlist(extractedIpaPath)
        extractProvisioningProfile(extractedIpaPath)
        
        return (true, nil)
    }
    
    class func createTempDir() -> NSURL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let tempDirPath = (systemTempDir as NSString).stringByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
//        println("tempDirUrl = \(tempDirUrl!)") // TODO: find properway of doing configurable logging, preferably at least as powerful as Android logging
        
        var error:NSError?
        let created: Bool
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(tempDirUrl, withIntermediateDirectories: true, attributes: nil)
            created = true
        } catch var error1 as NSError {
            error = error1
            created = false
        }

        assert(created, "Failed to create temp dir: \(error!.description)")

        return created ? tempDirUrl : nil
    }
    
    func extractAppName(extractedIpaPath:String)
    {
        let payloadDir:String = (extractedIpaPath as NSString).stringByAppendingPathComponent("Payload")
        let contents = (try! NSFileManager.defaultManager().contentsOfDirectoryAtPath(payloadDir)) 
        appName = contents[0]
        appPath = (payloadDir as NSString).stringByAppendingPathComponent(appName)
    }
    
    func extractInfoPlist(extractedIpaPath:String)
    {
        let infoPlistPath = (appPath as NSString).stringByAppendingPathComponent("Info.plist")
        infoPlistContents = NSDictionary(contentsOfFile: infoPlistPath)
        assert(infoPlistContents != nil)
    }
    
    func extractProvisioningProfile(extractedIpaPath:String)
    {
        let inputFileName = (appPath as NSString).stringByAppendingPathComponent("embedded.mobileprovision")
        provisioningProfile = ITProvisioningProfile.loadFromPath(inputFileName)
    }

}
