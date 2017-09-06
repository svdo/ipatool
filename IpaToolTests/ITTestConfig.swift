//
//  ITTestConfig.swift
//  ipatool
//
//  Created by Stefan on 15/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

extension FileManager {
    func findPathOfFile(_ name:String, startPath:NSString, maxLevelsUp: Int, maxLevelsDown: Int) -> String? {
        let filePath = startPath.appendingPathComponent(name)
        if fileExists(atPath: filePath) {
            return filePath
        }
        if (maxLevelsUp > 0) {
            let parent = startPath.deletingLastPathComponent
            return findPathOfFile(name, startPath: parent as NSString, maxLevelsUp: maxLevelsUp - 1, maxLevelsDown: maxLevelsDown)
        }
        if (maxLevelsDown > 0) {
            if let subFolders = subpaths(atPath: startPath as String) {
                for sub in subFolders {
                    if let s = findPathOfFile(name, startPath: sub as NSString, maxLevelsUp: 0, maxLevelsDown: maxLevelsDown - 1) {
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
    fileprivate var config:NSDictionary? = nil

    var ipaPath:String { get { return "SampleApp.ipa" } }
    var ipaFullPath:String? { get {
        let bundlePath = Bundle(for:type(of: self)).bundlePath
        let fullPath = FileManager.default.findPathOfFile(self.ipaPath, startPath: bundlePath as NSString, maxLevelsUp: 3, maxLevelsDown: 5)
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
    var provisioningExpiration:Date? { get {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df.date(from: config!["provisioningExpiration"] as! String)
        } }
    var provisioningAppIdName:String { get { return config!["provisioningAppIdName"] as! String } }
    var provisioningTeam:String { get { return config!["provisioningTeam"] as! String } }
    var resignedProvisioningName:String { get { return config!["resignedProvisioningName"] as! String } }
    var resignedCodeSigningAuthority:String { get { return config!["resignedCodeSigningAuthority"] as! String } }
    var resignProvisioningProfilePath:String { get {
        let fileName = config!["resignProvisioningProfilePath"] as! String
        return Bundle(for: type(of: self)).path(forResource: fileName, ofType: nil)!
        } }
    var resignedBundleIdentifier:String { get { return config!["resignedBundleIdentifier"] as! String } }

    func load() {
        let bundle = Bundle(for: type(of: self))
        let configFilePath:String? = bundle.path(forResource: "testConfig", ofType: "json")
        assert(configFilePath != nil)
        
        var jsonData: Data? = nil
        do {
            jsonData = try Data(contentsOf: URL(fileURLWithPath: configFilePath!), options:NSData.ReadingOptions(rawValue: 0))
        } catch {}
        assert(jsonData != nil)
        
        var config: NSDictionary? = nil
        do {
            config = try JSONSerialization.jsonObject(with: jsonData!, options:[]) as? NSDictionary
        } catch {}
        assert(config != nil)
        
        self.config = config
    }
    
   
}
