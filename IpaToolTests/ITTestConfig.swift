//
//  ITTestConfig.swift
//  ipatool
//
//  Created by Stefan on 15/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

extension NSFileManager {
    func findPathOfFile(name:String, startPath:NSString, maxLevelsUp: Int, maxLevelsDown: Int) -> String? {
        let filePath = startPath.stringByAppendingPathComponent(name)
        if fileExistsAtPath(filePath) {
            return filePath
        }
        if (maxLevelsUp > 0) {
            let parent = startPath.stringByDeletingLastPathComponent
            return findPathOfFile(name, startPath: parent, maxLevelsUp: maxLevelsUp - 1, maxLevelsDown: maxLevelsDown)
        }
        if (maxLevelsDown > 0) {
            if let subFolders = subpathsAtPath(startPath as String) {
                for sub in subFolders {
                    if let s = findPathOfFile(name, startPath: sub, maxLevelsUp: 0, maxLevelsDown: maxLevelsDown - 1) {
                        return s
                    }
                }
            }
        }
        return nil
    }
}

class ITTestConfig
{
    private var config:NSDictionary? = nil

    var ipaPath:String { get { return "SampleApp.ipa" } }
    var ipaFullPath:String? { get {
        let bundlePath = NSBundle(forClass:self.dynamicType).bundlePath
        let fullPath = NSFileManager.defaultManager().findPathOfFile(self.ipaPath, startPath: bundlePath, maxLevelsUp: 3, maxLevelsDown: 5)
        assert(fullPath != nil, "Could not find SampleApp.ipa")
        return fullPath
        } }
    var appName:String { get { return "SampleApp.app" } }
    var displayName:String { get { return "Sample!" } }
    var bundleShortVersionString:String { get { return "1.0" } }
    var bundleVersion:String { get { return "1" } }
    var bundleIdentifier:String { get { return config!["bundleIdentifier"] as! String } }
    var minimumOSVersion:String { get { return "8.0" } }
    var deviceFamily:String { get { return "iphone ipad" } }
    var codeSigningAuthority:String { get { return config!["codeSigningAuthority"] as! String } }
    var provisioningName:String { get { return config!["provisioningName"] as! String } }
    var provisioningExpiration:NSDate? { get {
        let df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df.dateFromString(config!["provisioningExpiration"] as! String)
        } }
    var provisioningAppIdName:String { get { return config!["provisioningAppIdName"] as! String } }
    var provisioningTeam:String { get { return config!["provisioningTeam"] as! String } }
    var resignedProvisioningName:String { get { return config!["resignedProvisioningName"] as! String } }
    var resignedCodeSigningAuthority:String { get { return config!["resignedCodeSigningAuthority"] as! String } }
    var resignProvisioningProfilePath:String { get {
        let fileName = config!["resignProvisioningProfilePath"] as! String
        return NSBundle(forClass: self.dynamicType).pathForResource(fileName, ofType: nil)!
        } }
    var resignedBundleIdentifier:String { get { return config!["resignedBundleIdentifier"] as! String } }

    func load() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let configFilePath:String? = bundle.pathForResource("testConfig", ofType: "json")
        assert(configFilePath != nil)
        
        var jsonData: NSData? = nil
        do {
            jsonData = try NSData(contentsOfFile:configFilePath!, options:NSDataReadingOptions(rawValue: 0))
        } catch {}
        assert(jsonData != nil)
        
        var config: NSDictionary? = nil
        do {
            config = try NSJSONSerialization.JSONObjectWithData(jsonData!, options:[]) as? NSDictionary
        } catch {}
        assert(config != nil)
        
        self.config = config
    }
    
   
}
