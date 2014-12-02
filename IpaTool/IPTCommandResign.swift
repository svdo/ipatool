//
//  IPTCommandResign.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class IPTCommandResign : ITCommand
{
    var ipaPath:String = ""
    var resignedPath:String { get { return IPTCommandResign.resignedPathForPath(ipaPath) } }
    var codesignAllocate:String? {
        get {
            let cmd = IPTSystemCommand()
            let ok = cmd.execute("/usr/bin/xcrun", ["--find", "codesign_allocate"])
            if (ok) {
                return cmd.standardOutput!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            }
            else {
                return nil
            }
        }
    }

    class func resignedPathForPath(path:String) -> String {
        return path.stringByDeletingPathExtension + "_resigned.ipa"
    }

    override func execute(args: [String]) -> String {
        var ipa = ITIpa()
        ipaPath = args[0]
        let (success,error) = ipa.load(ipaPath)
        if !success {
            return "Error: " + error
        }
        
        return resign(ipa, args[1])
    }
    
    func resign(ipa:ITIpa, _ provPath:String) -> String {
        var error:NSError? = nil
        
        if let alloc = codesignAllocate {
            let prof = ITProvisioningProfile.loadFromPath(provPath)
            if prof == nil {
                return "Error: could not load provisioning profile from path \(provPath)"
            }

            copyProvisioningProfileToExtractedIpa(ipa, provPath)
            let signer = prof!.codeSigningAuthority()!
            let cmd = IPTSystemCommand()
            let appName = ipa.appName
            let args:[String] = ["-f", "-vv", "-s", signer, appName]
            let env:[String:String] = ["CODESIGN_ALLOCATE":alloc, "EMBEDDED_PROFILE_NAME":"embedded.mobileprovision"]
            let payloadDir = ipa.appPath.stringByDeletingLastPathComponent
            cmd.workingDirectory = payloadDir
            var ok = cmd.execute("/usr/bin/codesign", args, env)
            
            if !ok {
                return error!.description
            }
            
            ok = SSZipArchive.createZipFileAtPath(resignedPath, withContentsOfDirectory: payloadDir.stringByDeletingLastPathComponent)
            if ok {
                return "\(ipa.appName): replacing existing signature\n" + "\n" + "Resigned ipa: \(resignedPath)\n"
            }
            else {
                return "Failed to create resigned IPA archive"
            }
        }
        else {
            return "Could not find codesign_allocate"
        }
    }
    
    func copyProvisioningProfileToExtractedIpa(ipa:ITIpa, _ provPath:String)
    {
        var error:NSError?
        let dest = ipa.appPath.stringByAppendingPathComponent("embedded.mobileprovision")
        NSFileManager.defaultManager().removeItemAtPath(dest, error: nil)
        let ok = NSFileManager.defaultManager().copyItemAtPath(provPath, toPath: dest, error: &error)
        assert(ok && error == nil, error!.description)
    }

}