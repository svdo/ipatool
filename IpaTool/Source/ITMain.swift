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
        let commandName = "usage";
        let command = commandFactory.commandWithName(commandName)
        var output:String
        if let c = command {
            output = c.execute(args)
        }
        else {
            output = "Invocation error. Please refer to documentation."
        }
        return output
    }
}

