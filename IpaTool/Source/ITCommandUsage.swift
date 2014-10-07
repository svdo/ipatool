//
//  ITCommandUsage.swift
//  IpaTool
//
//  Created by Stefan on 04/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

@objc(ITCommandUsage) class ITCommandUsage : ITCommand
{
    
    override class func initialize()
    {
        ITCommandFactory.registerCommand("usage", command:ITCommandUsage())
    }
    
}
