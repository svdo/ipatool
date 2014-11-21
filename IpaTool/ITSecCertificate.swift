//
//  ITSecCertificate.swift
//  ipatool
//
//  Created by Stefan on 21/11/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITSecCertificate
{
    var _secCertificate:SecCertificate
    
    init(_ secCertificate:SecCertificate)
    {
        _secCertificate = secCertificate
    }
    
    var commonName : String? {
        get {
            var cn:Unmanaged<CFString>? = nil
            SecCertificateCopyCommonName(_secCertificate, &cn)
            if let c = cn {
                return c.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
    
    var subject : String? {
        get {
            var subject:Unmanaged<CFString>? = SecCertificateCopySubjectSummary(_secCertificate)
            if let s = subject {
                return s.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
    
    var description : String? {
        get {
            var desc:Unmanaged<CFString>? = SecCertificateCopyShortDescription(nil, _secCertificate, nil)
            if let d = desc {
                return d.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
    
    var normalizedSubjectContent : NSData? {
        get {
            var nSubCont:Unmanaged<CFData>? = SecCertificateCopyNormalizedSubjectContent(_secCertificate, nil)
            if let n = nSubCont {
                return n.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
    
    var longDescription : String? {
        get {
            var longDesc:Unmanaged<CFString>? = SecCertificateCopyLongDescription(nil, _secCertificate, nil)
            if let d = longDesc {
                return d.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
    
    var values : NSDictionary? {
        get {
            var certValues = SecCertificateCopyValues(_secCertificate, nil, nil)
            if let c = certValues {
                return c.takeRetainedValue()
            }
            else {
                return nil
            }
        }
    }
}
