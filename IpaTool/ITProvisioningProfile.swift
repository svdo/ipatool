//
//  ITProvisioningProfile.swift
//  ipatool
//
//  Created by Stefan on 21/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITProvisioningProfile
{
    var provisioningProfile:NSDictionary?
    
    init(_ data:NSData)
    {
        provisioningProfile = NSPropertyListSerialization.propertyListFromData(data, mutabilityOption: NSPropertyListMutabilityOptions.Immutable, format: nil, errorDescription: nil) as? NSDictionary
    }
    
    func subjectCNForCertificateAtIndex(i:Int) -> String?
    {
        if let prof = provisioningProfile
        {
            var certs:[NSData] = prof["DeveloperCertificates"] as [NSData]
            var cert = certs[i]
            var secCert:ITSecCertificate = ITSecCertificate(cert)
            return secCert.subject
        }
        else {
            return nil;
        }
    }
}
