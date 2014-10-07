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
        var commandName = (args.count >= 2) ? args[1] : "usage"
        let command = commandFactory.commandWithName(commandName)
        return command
    }
}

