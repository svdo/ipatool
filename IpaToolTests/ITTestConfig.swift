//
//  ITTestConfig.swift
//  ipatool
//
//  Created by Stefan on 15/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITTestConfig
{
    private var config:NSDictionary? = nil

    var ipaPath:String { get { return config!["ipaPath"] as String } }
    var ipaFullPath:String? { get {
        let bundle = NSBundle(forClass: self.dynamicType)
        let ipaFullPath = bundle.pathForResource(self.ipaPath.stringByDeletingPathExtension, ofType:"ipa")
        return ipaFullPath
        } }
    var appName:String { get { return config!["appName"] as String } }
    var displayName:String { get { return config!["displayName"] as String } }
    var bundleShortVersionString:String { get { return config!["bundleShortVersionString"] as String } }
    var bundleVersion:String { get { return config!["bundleVersion"] as String } }
    var bundleIdentifier:String { get { return config!["bundleIdentifier"] as String } }
    var minimumOSVersion:String { get { return config!["minimumOSVersion"] as String } }
    var codeSigningAuthority:String { get { return config!["codeSigningAuthority"] as String } }
    var provisioningName:String { get { return config!["provisioningName"] as String } }
    var provisioningExpiration:NSDate? { get {
        var df = NSDateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return df.dateFromString(config!["provisioningExpiration"] as String)
        } }
    var provisioningAppIdName:String { get { return config!["provisioningAppIdName"] as String } }
    var provisioningTeam:String { get { return config!["provisioningTeam"] as String } }

    func load() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let configFilePath:String? = bundle.pathForResource("testConfig", ofType: "json")
        assert(configFilePath != nil)
        
        var error:NSError?
        let jsonData = NSData(contentsOfFile:configFilePath!, options:NSDataReadingOptions(0), error: &error)
        assert(jsonData != nil)
        let config: NSDictionary? = NSJSONSerialization.JSONObjectWithData(jsonData!, options:NSJSONReadingOptions(0), error:&error) as? NSDictionary
        assert(config != nil)
        
        self.config = config
    }
    
   
}
