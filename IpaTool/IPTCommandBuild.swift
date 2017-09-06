//
//  IPTCommandBuild.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class IPTCommandBuild : ITCommand
{
    override func execute(_ args: [String]) -> String {
        let ipa = ITIpa()
        let (success,error) = ipa.load(args[0])
        
        if (success) {
            return ipa.bundleVersion;
        }
        else {
            return "Error: " + (error ?? "(nil)")
        }
    }
    
}
