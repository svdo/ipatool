//
//  ITIpa.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

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
            try NSFileManager.defaultManager().removeItemAtPath(extractedIpaPath);
        } catch _ {
            /* error happens */
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
        //let tempDirPath = systemTempDir.URLByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
//      print("tempDirUrl = \(tempDirUrl!)") // TODO: find properway of doing configurable logging, preferably at least as powerful as Android logging
        let tempDirString = tempDirUrl.absoluteString
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(tempDirString, withIntermediateDirectories:true, attributes:nil);
            return tempDirUrl;
        } catch _ {
            print("Failed to create temp dir: \(tempDirString)");
            return nil;
        }
    }
    
    func extractAppName(extractedIpaPath:String)
    {
        let payloadDir:String = (extractedIpaPath as NSString).stringByAppendingPathComponent("Payload")
        do {
          let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(payloadDir);
          appName = contents[0]
          appPath = (payloadDir as NSString).stringByAppendingPathComponent(appName)
        } catch _ {
          /* error happens */
        }
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
