//
//  ITCMSDecoder.swift
//  ipatool
//
//  Created by Stefan on 20/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITCMSDecoder
{
    var cmsDecoder:CMSDecoder?
    var _decodedString:String?
    
    init()
    {
        var d: Unmanaged<CMSDecoder>? = nil
        var status = CMSDecoderCreate(&d)
        assert(status == noErr)
        cmsDecoder = d!.takeRetainedValue()
    }
    
    func decodeData(data:NSData)
    {
        let l = data.length
        var bytes = UnsafeMutablePointer<Void>.alloc(l)
        data.getBytes(bytes, length:l)
        var status = CMSDecoderUpdateMessage(cmsDecoder, bytes, UInt(l))
        assert(status == noErr)
        
        status = CMSDecoderFinalizeMessage(cmsDecoder)
        assert(status == noErr)
    }
    
    func decodedString() -> String?
    {
        if (_decodedString != nil) { return _decodedString }
        if (cmsDecoder == nil) { return nil }
        
        var data:Unmanaged<CFData>? = nil
        var status = CMSDecoderCopyContent(cmsDecoder, &data)
        assert(status == noErr)
        let decodedData:NSData = data!.takeRetainedValue()
        _decodedString = NSString(data: decodedData, encoding: NSUTF8StringEncoding)
        return _decodedString
    }

    func numberOfSigners() -> UInt
    {
        var numSigners:UInt = 0
        var status = CMSDecoderGetNumSigners(cmsDecoder, &numSigners)
        assert(status == noErr)
        println("Num signers: " + String(numSigners))
        assert(numSigners == 1) // todo convert to run-time error
        return numSigners
    }
}


/*

var d: Unmanaged<CMSDecoder>? = nil
var status = CMSDecoderCreate(&d)
assert(status == noErr)
var cmsDecoder: CMSDecoder = d!.takeRetainedValue()


let l = provisioningData!.length
var bytes = UnsafeMutablePointer<Void>.alloc(l)
provisioningData?.getBytes(bytes, length:l)
status = CMSDecoderUpdateMessage(cmsDecoder, bytes, UInt(l))
assert(status == noErr)

status = CMSDecoderFinalizeMessage(cmsDecoder)
assert(status == noErr)

var data:Unmanaged<CFData>? = nil
status = CMSDecoderCopyContent(cmsDecoder, &data)
assert(status == noErr)
let decodedData:NSData = data!.takeRetainedValue()
let decodedString = NSString(data: decodedData, encoding: NSUTF8StringEncoding)

var numSigners:UInt = 0
status = CMSDecoderGetNumSigners(cmsDecoder, &numSigners)
assert(status == noErr)
println("Num signers: " + String(numSigners))
assert(numSigners == 1) // todo convert to run-time error

*/