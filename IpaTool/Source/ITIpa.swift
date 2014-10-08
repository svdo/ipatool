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
    var appName:String! = nil
    
    func load(path:String) -> (result:Bool, error:String!)
    {
        let tempDirUrl = ITIpa.createTempDir()
        let tempPath:String = tempDirUrl.path!
        let ok = SSZipArchive.unzipFileAtPath(path, toDestination: tempPath)
        if !ok {
            return (false, "could not extract ipa")
        }
        
        let payloadDir:String = tempPath.stringByAppendingPathComponent("Payload")
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(payloadDir, error: nil) as [String]
        appName = contents[0]
        
        NSFileManager.defaultManager().removeItemAtPath(tempPath, error: nil)
        return (true, nil)
    }
    
    class func createTempDir() -> NSURL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let tempDirPath = systemTempDir.stringByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
        println("tempDirUrl = \(tempDirUrl!)")
        
        var error:NSError?
        let created = NSFileManager.defaultManager().createDirectoryAtURL(tempDirUrl!, withIntermediateDirectories: true, attributes: nil, error: &error)

        assert(created, "Failed to create temp dir: \(error!.description)")

        return created ? tempDirUrl : nil
    }
    

    
}
