//
//  IPTCommandVersion.swift
//  ipatool
//
//  Created by Stefan on 28/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class IPTCommandVersion : ITCommand
{
    override func execute(args: [String]) -> String {
        var ipa = ITIpa()
        let (success,error) = ipa.load(args[0])
        
        if (success) {
            return ipa.bundleShortVersionString;
        }
        else {
            return "Error: " + error
        }
    }
}
