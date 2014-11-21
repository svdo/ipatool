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
    private var _decodedString:String?
    private var _decodedData:NSData?
    
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
        
        decodeString()
    }
    
    func decodeString()
    {
        var data:Unmanaged<CFData>? = nil
        var status = CMSDecoderCopyContent(cmsDecoder, &data)
        assert(status == noErr)
        if let d = data {
            _decodedData = d.takeRetainedValue()
            _decodedString = NSString(data:_decodedData!, encoding: NSUTF8StringEncoding)
        }
    }
    
    func decodedString() -> String?
    {
        if (_decodedString != nil) { return _decodedString }
        if (cmsDecoder == nil) { return nil }
        decodeString()
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
    
    func trust() -> ITSecTrust
    {
        var policyRef:Unmanaged<SecPolicy> = SecPolicyCreateBasicX509()
        var secPolicy = policyRef.takeRetainedValue()
        var signerStatus:CMSSignerStatus = 0
        var evaluateSecTrust: Boolean = 0
        var secTrust:Unmanaged<SecTrust>? = nil
        var certVerifyResultCode:OSStatus = noErr
        var status = CMSDecoderCopySignerStatus(cmsDecoder, 0, secPolicy, evaluateSecTrust, &signerStatus, &secTrust, &certVerifyResultCode)
        assert(status == noErr)
        assert(certVerifyResultCode == noErr) // todo: convert to run-time error (SecCopyErrorMessageString?)
        assert(signerStatus == UInt32(kCMSSignerValid)) // todo: convert to run-time error
        var trust = secTrust!.takeRetainedValue()
        return ITSecTrust(trust)
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