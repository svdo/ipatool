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
    
    init(_ data:Data)
    {
        provisioningProfile = (try? PropertyListSerialization.propertyList(from: data, options: PropertyListSerialization.MutabilityOptions(), format: nil)) as? NSDictionary
    }
    
    class func loadFromPath(_ path:String) -> ITProvisioningProfile?
    {
        let provisioningData = try? Data(contentsOf: URL(fileURLWithPath: path))
        if provisioningData == nil {
            return nil
        }
        
        let decoder = ITCMSDecoder()
        decoder.decodeData(provisioningData!)
        return decoder.provisioningProfile()
    }
    
    func subjectCNForCertificateAtIndex(_ i:Int) -> String?
    {
        if let prof = provisioningProfile
        {
            var certs:[Data] = prof["DeveloperCertificates"] as! [Data]
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
    
    func expirationDate() -> Date?
    {
         return provisioningProfile!["ExpirationDate"] as? Date
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
