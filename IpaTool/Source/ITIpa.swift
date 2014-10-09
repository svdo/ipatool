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
    var appName:String = ""
    var appPath:String = ""
    var displayName:String = ""
    var bundleShortVersionString:String = ""
    var bundleVersion:String = ""
    
    func load(path:String) -> (result:Bool, error:String!)
    {
        let tempDirUrl = ITIpa.createTempDir()
        let extractedIpaPath:String = tempDirUrl.path!
        let ok = SSZipArchive.unzipFileAtPath(path, toDestination: extractedIpaPath)
        if !ok {
            return (false, "could not extract ipa")
        }
        
        extractAppName(extractedIpaPath)
        extractInfoPlist(extractedIpaPath)
        
        NSFileManager.defaultManager().removeItemAtPath(extractedIpaPath, error: nil)
        return (true, nil)
    }
    
    class func createTempDir() -> NSURL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let tempDirPath = systemTempDir.stringByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
//        println("tempDirUrl = \(tempDirUrl!)")
        
        var error:NSError?
        let created = NSFileManager.defaultManager().createDirectoryAtURL(tempDirUrl!, withIntermediateDirectories: true, attributes: nil, error: &error)

        assert(created, "Failed to create temp dir: \(error!.description)")

        return created ? tempDirUrl : nil
    }
    
    func extractAppName(extractedIpaPath:String)
    {
        let payloadDir:String = extractedIpaPath.stringByAppendingPathComponent("Payload")
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(payloadDir, error: nil) as [String]
        appName = contents[0]
        appPath = payloadDir.stringByAppendingPathComponent(appName)
    }
    
    func extractInfoPlist(extractedIpaPath:String)
    {
        let infoPlistPath = appPath.stringByAppendingPathComponent("Info.plist")
        var infoPlistContents = NSDictionary(contentsOfFile: infoPlistPath)
        displayName = infoPlistContents["CFBundleDisplayName"] as String
        bundleShortVersionString = infoPlistContents["CFBundleShortVersionString"] as String
        bundleVersion = infoPlistContents["CFBundleVersion"] as String
    }
}
