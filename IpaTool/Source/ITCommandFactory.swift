//
//  ITCommandFactory.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITCommandFactory
{
    class func registerCommand(name:String, command:ITCommand)
    {
        commandFactoryCommands[name] = command
    }
    
    var commands : Dictionary<String, ITCommand>
    {
        get
        {
            return commandFactoryCommands
        }
    }
}

private var commandFactoryCommands = Dictionary<String, ITCommand>()
