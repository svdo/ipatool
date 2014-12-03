//
//  ITMain.swift
//  IpaTool
//
//  Created by Stefan on 01/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITMain
{
    class func version() -> String {
        return "1.0"
    }
    
    let commandFactory : ITCommandFactory = ITCommandFactory()

    func run(args:[String]) -> String
    {
        let command = commandForArguments(args)
        var output:String
        if let c = command {
            output = c.execute(args)
        }
        else {
            output = "Invocation error. Please refer to documentation."
        }
        return output
    }
    
    func commandForArguments(args:[String]) -> ITCommand?
    {
        var commandName = ""
        switch (args.count) {
            case 0: commandName = "usage"
            case 1: commandName = "info"
            default: commandName = args[1]
        }
        var command = commandFactory.commandWithName(commandName)
        if command == nil {
            command = commandFactory.commandWithName("usage")
        }
        return command
    }
}

