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
        provisioningProfile = NSPropertyListSerialization.propertyListWithData(data, options: Int(NSPropertyListMutabilityOptions.Immutable.rawValue), format: nil, error: nil) as? NSDictionary
    }
    
    class func loadFromPath(path:String) -> ITProvisioningProfile?
    {
        let provisioningData = NSData(contentsOfFile:path)
        if provisioningData == nil {
            return nil
        }
        
        var decoder = ITCMSDecoder()
        decoder.decodeData(provisioningData!)
        var cmsDecoder = decoder.cmsDecoder
        return decoder.provisioningProfile()
    }
    
    func subjectCNForCertificateAtIndex(i:Int) -> String?
    {
        if let prof = provisioningProfile
        {
            var certs:[NSData] = prof["DeveloperCertificates"] as! [NSData]
            var cert = certs[i]
            var secCert:ITSecCertificate = ITSecCertificate(cert)
            return secCert.subject
        }
        else {
            return nil;
        }
    }
    
    func codeSigningAuthority() -> String?
    {
        return subjectCNForCertificateAtIndex(0)
    }
    
    func expirationDate() -> NSDate?
    {
         return provisioningProfile!["ExpirationDate"] as? NSDate
    }
    
    func provisioningName() -> String?
    {
        return provisioningProfile!["Name"] as? String
    }
    
    func appIdName() -> String?
    {
        return provisioningProfile!["AppIDName"] as? String
    }
    
    func teamName() -> String?
    {
        return provisioningProfile!["TeamName"] as? String
    }
}
