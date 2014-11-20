//
//  ITIpa.swift
//  IpaTool
//
//  Created by Stefan on 07/10/14.
//  Copyright (c) 2014 Stefan van den Oord. All rights reserved.
//

import Foundation

class ITIpa
{
    var appName = ""
    var appPath = ""
    
    var displayName:String { get { return infoPlistContents!["CFBundleDisplayName"] as String } }
    var bundleShortVersionString:String { get { return infoPlistContents!["CFBundleShortVersionString"] as String } }
    var bundleVersion:String { get { return infoPlistContents!["CFBundleVersion"] as String } }
    var bundleIdentifier:String { get { return infoPlistContents!["CFBundleIdentifier"] as String } }
    var minimumOSVersion:String { get { return infoPlistContents!["MinimumOSVersion"] as String } }
    var codeSigningAuthority = ""

    private var infoPlistContents:NSDictionary? = nil
    
    func load(path:String) -> (result:Bool, error:String!)
    {
        let tempDirUrl = ITIpa.createTempDir()
        let extractedIpaPath:String = tempDirUrl.path!
        let ok = SSZipArchive.unzipFileAtPath(path, toDestination: extractedIpaPath)
        if !ok {
            return (false, "could not extract ipa")
        }
        
        extractAppName(extractedIpaPath)
        extractInfoPlist(extractedIpaPath)
        extractCodeSigningAuthority(extractedIpaPath)
        
        NSFileManager.defaultManager().removeItemAtPath(extractedIpaPath, error: nil)
        return (true, nil)
    }
    
    class func createTempDir() -> NSURL!
    {
        let systemTempDir = NSTemporaryDirectory()
        let uniqueId = NSProcessInfo.processInfo().globallyUniqueString
        let tempDirPath = systemTempDir.stringByAppendingPathComponent(uniqueId)
        let tempDirUrl = NSURL.fileURLWithPath(tempDirPath, isDirectory: true)
//        println("tempDirUrl = \(tempDirUrl!)") // TODO: find properway of doing configurable logging, preferably at least as powerful as Android logging
        
        var error:NSError?
        let created = NSFileManager.defaultManager().createDirectoryAtURL(tempDirUrl!, withIntermediateDirectories: true, attributes: nil, error: &error)

        assert(created, "Failed to create temp dir: \(error!.description)")

        return created ? tempDirUrl : nil
    }
    
    func extractAppName(extractedIpaPath:String)
    {
        let payloadDir:String = extractedIpaPath.stringByAppendingPathComponent("Payload")
        let contents = NSFileManager.defaultManager().contentsOfDirectoryAtPath(payloadDir, error: nil) as [String]
        appName = contents[0]
        appPath = payloadDir.stringByAppendingPathComponent(appName)
    }
    
    func extractInfoPlist(extractedIpaPath:String)
    {
        let infoPlistPath = appPath.stringByAppendingPathComponent("Info.plist")
        infoPlistContents = NSDictionary(contentsOfFile: infoPlistPath)
    }
    
    func extractCodeSigningAuthority(extractedIpaPath:String)
    {
        let inputFileName = appPath.stringByAppendingPathComponent("embedded.mobileprovision")
        let provisioningData = NSData(contentsOfFile:inputFileName)
        assert(provisioningData != nil)
        
        var decoder = ITCMSDecoder()
        decoder.decodeData(provisioningData!)
        var cmsDecoder = decoder.cmsDecoder
        
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
        
        let numCerts = SecTrustGetCertificateCount(trust)
        var ucert:Unmanaged<SecCertificate>? = SecTrustGetCertificateAtIndex(trust, 0)
        var cert = ucert!.takeRetainedValue()
        
        var uCommonName:Unmanaged<CFString>? = nil
        SecCertificateCopyCommonName(cert, &uCommonName)
        var commonName:NSString = uCommonName!.takeRetainedValue()
        
        var uSubject:Unmanaged<CFString>? = SecCertificateCopySubjectSummary(cert)
        var subject:NSString = uSubject!.takeRetainedValue()
        
        var uDescription:Unmanaged<CFString>? = SecCertificateCopyShortDescription(nil, cert, nil)
        var description:NSString = uDescription!.takeRetainedValue()
        
        var uNormalizedSubjectContent:Unmanaged<CFData>? = SecCertificateCopyNormalizedSubjectContent(cert, nil)
        var normalizedSubjectContent:NSData = uNormalizedSubjectContent!.takeRetainedValue() // DER encoded certificate?
        
        var uLongDesc:Unmanaged<CFString>? = SecCertificateCopyLongDescription(nil, cert, nil)
        var longDesc:NSString = uLongDesc!.takeRetainedValue()
        
        var uCertValues = SecCertificateCopyValues(cert, nil, nil)
        var certValues:NSDictionary = uCertValues!.takeRetainedValue()
        var xx = certValues[kSecOIDX509V1SubjectName]
        
        println("done")
        return
        
        
//        var provisioningProfile:NSDictionary? = NSPropertyListSerialization.propertyListFromData(decodedData, mutabilityOption: NSPropertyListMutabilityOptions.Immutable, format: nil, errorDescription: nil) as? NSDictionary
//        assert(provisioningProfile != nil)
//        
//        var certs:[NSData] = provisioningProfile!["DeveloperCertificates"] as [NSData]
//        var cert0 = certs[0]
//        
//        var cert0Bytes = UnsafeMutablePointer<UInt8>.alloc(cert0.length)
//        cert0.getBytes(cert0Bytes, length:cert0.length)
//        var cfrs = CFReadStreamCreateWithBytesNoCopy(nil, cert0Bytes, cert0.length, nil)
//        
//        var uReadTransform:Unmanaged<SecTransform>? = SecTransformCreateReadTransformWithReadStream(cfrs);
//        var readTransform: SecTransform = uReadTransform!.takeRetainedValue()
//        
//        var uDecoder = SecDecodeTransformCreate(kSecBase64Encoding, nil)
//        var decoder: SecTransform = uDecoder!.takeRetainedValue()
//        var out:AnyObject = SecTransformExecute(decoder, nil)
//        
//        var uGroup:Unmanaged<SecGroupTransform>! = SecTransformCreateGroupTransform()
//        var group: SecGroupTransform = uGroup!.takeRetainedValue()
//        SecTransformConnectTransforms(readTransform, kSecTransformOutputAttributeName,
//            decoder, kSecTransformInputAttributeName, group, nil);
//        
//        var base64decodedData = SecTransformExecute(group, nil)
//        
//        println(cert)

    }
}
