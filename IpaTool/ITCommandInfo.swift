//
//  ITCommandInfo.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITCommandInfo : ITCommand
{
    override func execute(args: [String]) -> String {
        var ipa = ITIpa()
        let (success,error) = ipa.load(args[0])

        if (success) {
            return ipa.displayName
        }
        else {
            return "Error: " + error
        }
    }
}
