//
//  ITSecTrust.swift
//  ipatool
//
//  Created by Stefan on 21/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITSecTrust
{
    var _secTrust:SecTrust

    init(_ secTrust:SecTrust)
    {
        _secTrust = secTrust
    }
    
    func numberOfCertificates() -> Int
    {
        return SecTrustGetCertificateCount(_secTrust)
    }
    
    func certificateAtIndex(index:Int) -> ITSecCertificate
    {
        var cert:Unmanaged<SecCertificate>? = SecTrustGetCertificateAtIndex(_secTrust, index)
        return ITSecCertificate(cert!.takeRetainedValue())
    }
}
