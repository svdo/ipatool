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
        
        if (success) {
            return resign(ipa)
        }
        else {
            return "Error: " + error
        }
    }
    
    func resign(ipa:ITIpa) -> String {
        var error:NSError? = nil
        let ok = NSFileManager.defaultManager().copyItemAtPath(ipaPath, toPath:resignedPath, error: &error)
        
        if (ok) {
            return "\(ipa.appName): replacing existing signature\n" + "\n" + "Resigned ipa: \(resignedPath)\n"
        }
        else {
            return error!.description
        }

    }
}