ipatool
=======

Shell script to query iOS IPA files and to resign an IPA with a new provisioning profile. Sample use cases:

   * Check expiration of enterprise-signed IPAs so that you know when you have to ship new releases to your customers.
   * Resign enterprise-signed IPA that has expired with a new provisioning profile.
   * Resign appstore-signed IPA with enterprise provisioning profile, so that you can test the actual binary that you will upload to Apple.
   
Since this is a standard shell script, you can of course use it in continuous integration setups such as Jenkins etc.

Query IPA files
---------------
Invocation: `ipatool.sh myapp.ipa`

Sample output:
<pre>
  App name:            My App.app
  Display name:        My App
  Version:             1.0
  Build:               21
  Bundle identifier:   com.example.myapp
  Code sign authority: iPhone Distribution: Example Inc.
  Minimum OS version:  6.0
  Device family:       iphone ipad 

Provisioning:
  Name:                My App - AppStore
  Expiration:          Fri Dec 11 10:22:40 CET 2013
  App ID name:         My App
  Team:                Example Team
</pre>

Resign IPA files
----------------
Invocation: `ipatool.sh myapp.ipa resign provisioning-profile enterpriseprof.mobileprovision bundle-identifier com.example.enterprise.myapp`

This invocation will resign the IPA using the provisioning profile found in `enterpriseprof.mobileprovision`. In the process, it will change the bundle identifier to `com.example.enterprise.myapp`.