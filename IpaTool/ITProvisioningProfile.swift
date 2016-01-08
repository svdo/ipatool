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
        do {
            provisioningProfile = try NSPropertyListSerialization.propertyListWithData(data,
                options: NSPropertyListMutabilityOptions.Immutable, format: nil) as? NSDictionary
        } catch _ {
            fatalError("Cannot initialize the provisioning profile");
        }
    }
    
    class func loadFromPath(path:String) -> ITProvisioningProfile?
    {
        let provisioningData = NSData(contentsOfFile:path)
        if provisioningData == nil {
            return nil
        }
        
        let decoder = ITCMSDecoder()
        decoder.decodeData(provisioningData!)
        //let cmsDecoder = decoder.cmsDecoder
        return decoder.provisioningProfile()
    }
    
    func subjectCNForCertificateAtIndex(i:Int) -> String?
    {
        if let prof = provisioningProfile
        {
            let certs:[NSData] = prof["DeveloperCertificates"] as! [NSData]
            let cert = certs[i]
            let secCert:ITSecCertificate = ITSecCertificate(cert)
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
