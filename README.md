ipatool ![](https://travis-ci.org/svdo/ipatool.svg)
=======

Quick Start
-----------

   1. Download and extract latest release sources (or clone master)
   2. Inside the source folder, run the shell script `./buildAndInstall.sh`
   
This will install ipatool in `/usr/local/bin`. You can easily customize the installation
location by editing the script.

You can now run it by executing `/usr/local/bin/ipatool`. See below for details on
command line options.

Introduction
------------
Command line utility to query iOS IPA files and to resign an IPA with a new provisioning
profile (and optionally a new bundle identifier). Sample use cases:

   * Check expiration of enterprise-signed IPAs so that you know when you have to ship
     new releases to your customers.
   * Resign enterprise-signed IPA that has expired with a new provisioning profile.
   * Resign appstore-signed IPA with enterprise provisioning profile, so that you can
     test the actual binary that you will upload to Apple.
   
Since this is a command line utility, you can of course use it in continuous integration
setups such as Jenkins etc.

Query IPA files
---------------
Invocation: `ipatool myapp.ipa`

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
Invocation: `ipatool myapp.ipa resign enterpriseprof.mobileprovision com.example.enterprise.myapp`

This invocation will resign the IPA using the provisioning profile found in
`enterpriseprof.mobileprovision`. In the process, it will change the bundle identifier
to `com.example.enterprise.myapp`.

Note for Developers
===================
The unit tests work on an actual ipa that is also part of this project. It is built using
a shell script build phase in the `ipatoolTests` target. This means that it will be
code-signed using your own certificate and provisioning profile.

The tests check whether the code signing that this `SampleApp.ipa` has matches what is
expected. Since this will be different for everybody, the expected values are put in
`testConfig.json`. In order for the tests to pass, you will have to modify
`testConfig.json` so that it contains the values that are valid for you.

Wiki
====
Please refer to the wiki for more information on [Managing Archives and Code Signing with
xcodebuild](https://github.com/svdo/ipatool/wiki/Managing-Archives-and-Code-Signing-with-xodebuild).

TODO
====
* Use `IPT` class prefix everywhere instead of `IT`.
