//
//  IPTSystemCommand.swift
//  ipatool
//
//  Created by Stefan on 01/12/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class IPTSystemCommand
{
    var exitCode:Int32 = 0
    var standardOutput:String? = nil
    var workingDirectory:String? = nil
    
    func execute(cmd:String, _ args:[String] = [], _ env:[String:String] = [:]) -> Bool {
        let stdOutPipe = NSPipe()
        let stdOut = stdOutPipe.fileHandleForReading
        
        let task = NSTask()
        task.launchPath = cmd
        if args.count > 0 {
            task.arguments = args
        }
        if env.count > 0 {
            task.environment = env
        }
        if workingDirectory != nil {
            task.currentDirectoryPath = workingDirectory!
        }
        task.standardOutput = stdOutPipe
        task.launch()

        let stdOutData = NSMutableData()
        while (task.running) {
            stdOutData.appendData(stdOut.readDataToEndOfFile())
        }
        stdOutData.appendData(stdOut.readDataToEndOfFile())
        stdOut.closeFile()
        standardOutput = NSString(data:stdOutData, encoding:NSUTF8StringEncoding) as String?
        
        exitCode = task.terminationStatus
        return exitCode == 0
    }
}
