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
    struct Statics {
        static var commandFactoryCommands:Dictionary<String, ITCommand> = [
            "info" : ITCommandInfo(),
            "usage": ITCommandUsage(),
            "version": IPTCommandVersion()]
    }
    
    var commands : Dictionary<String, ITCommand>
        {
        get
        {
            return ITCommandFactory.Statics.commandFactoryCommands
        }
    }
    
    func commandWithName(name:String) -> ITCommand?
    {
        return ITCommandFactory.Statics.commandFactoryCommands[name]
    }
}

