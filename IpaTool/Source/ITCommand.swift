//
//  ITCommand.swift
//  IpaTool
//
//  Created by Stefan on 01/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

@objc(ITCommand) class ITCommand : NSObject
{
    func execute(args:[String]) -> String
    {
        fatalError("abstract method")
    }
}
