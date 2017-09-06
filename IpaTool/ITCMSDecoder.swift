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
    var cmsDecoder:CMSDecoder!
    private var _decodedString:String?
    private var _decodedData:Data?
    
    init()
    {
        var d:CMSDecoder? = nil
        let status = CMSDecoderCreate(&d)
        assert(status == noErr)
        cmsDecoder = d
    }
    
    func decodeData(_ data:Data)
    {
        let l = data.count
        var bytes = [UInt8](repeating: 0, count: l)
        (data as NSData).getBytes(&bytes, length:l)
        var status = CMSDecoderUpdateMessage(cmsDecoder, bytes, Int(l))
        assert(status == noErr)
        
        status = CMSDecoderFinalizeMessage(cmsDecoder)
        assert(status == noErr)
        
        decodeString()
    }
    
    func decodeString()
    {
        var data:CFData? = nil
        let status = CMSDecoderCopyContent(cmsDecoder, &data)
        assert(status == noErr)
        if let d = data {
            _decodedData = d as Data
            _decodedString = NSString(data:_decodedData!, encoding: String.Encoding.utf8.rawValue) as String?
        }
    }
    
    func decodedString() -> String?
    {
        if (_decodedString != nil) { return _decodedString }
        if (cmsDecoder == nil) { return nil }
        decodeString()
        return _decodedString
    }

    func provisioningProfile() -> ITProvisioningProfile?
    {
        if let d = _decodedData {
            return ITProvisioningProfile(d)
        }
        else {
            return nil
        }
    }
}
