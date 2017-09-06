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
            return result.trimmingCharacters(in: CharacterSet.whitespaces)
        }
    }
    var provisioningProfile:ITProvisioningProfile? = nil
    fileprivate var infoPlistContents:NSDictionary? = nil
    
    deinit
    {
        do {
            try FileManager.default.removeItem(atPath: extractedIpaPath)
        } catch _ {
        }
    }
    
    func load(_ path:String) -> (result:Bool, error:String?)
    {
        let tempDirUrl = ITIpa.createTempDir()
        extractedIpaPath = tempDirUrl!.path

        if !FileManager.default.isReadableFile(atPath: path) {
            return (false, "File not found: \(path)")
        }
        
        let ok = SSZipArchive.unzipFile(atPath: path, toDestination: extractedIpaPath)
        if !ok {
            return (false, "Failed to extract \(path)")
        }
        
        extractAppName(extractedIpaPath)
        extractInfoPlist(extractedIpaPath)
        extractProvisioningProfile(extractedIpaPath)
        
        return (true, nil)
    }
    
    class func createTempDir() -> URL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = ProcessInfo.processInfo.globallyUniqueString
        let tempDirPath = (systemTempDir as NSString).appendingPathComponent(uniqueId)
        let tempDirUrl = URL(fileURLWithPath: tempDirPath, isDirectory: true)
        
        do {
            try FileManager.default.createDirectory(at: tempDirUrl, withIntermediateDirectories: true, attributes: nil)
        } catch let e {
            assert(false, "Failed to create temp dir: \(e)")
            return nil
        }

        return tempDirUrl
    }
    
    func extractAppName(_ extractedIpaPath:String)
    {
        let payloadDir:String = (extractedIpaPath as NSString).appendingPathComponent("Payload")
        let contents = (try! FileManager.default.contentsOfDirectory(atPath: payloadDir)) 
        appName = contents[0]
        appPath = (payloadDir as NSString).appendingPathComponent(appName)
    }
    
    func extractInfoPlist(_ extractedIpaPath:String)
    {
        let infoPlistPath = (appPath as NSString).appendingPathComponent("Info.plist")
        infoPlistContents = NSDictionary(contentsOfFile: infoPlistPath)
        assert(infoPlistContents != nil)
    }
    
    func extractProvisioningProfile(_ extractedIpaPath:String)
    {
        let inputFileName = (appPath as NSString).appendingPathComponent("embedded.mobileprovision")
        provisioningProfile = ITProvisioningProfile.loadFromPath(inputFileName)
    }

}
