#!/bin/bash

#
# Subject to MIT License (MIT), see LICENSE.
#
# For documentation, refer to README.md.
#

scriptDir="`dirname $0`"
scriptName="`basename $0`"
absScriptDir="`cd $scriptDir; pwd`"

fatal() {
	echo "[fatal] $1" 1>&2
	delete_temps
	exit 1
}

absPath() {
	case "$1" in
		/*)
			printf "%s\n" "$1"
			;;
		*)
			printf "%s\n" "$PWD/$1"
			;;
	esac;
}

usage() {
	echo "Usage: $scriptName IPA [OPTIONS]"
	echo "IPA is a file with extension '.ipa'"
	echo ""
	echo "Available options:"
	echo "  info [default]  Shows high level info about the IPA"
	echo "  version         Shows the version number (CFBundleShortVersionString)"
	echo "  build           Shows the build number (CFBundleVersion)"
	echo "  extract-certs   Extracts certificates used for code signing and writes them"
	echo "                  to files in the current working directory."
	echo "  expiration      Shows expiration date of the embedded provisioning profile"
	echo "  resign          Resign the IPA and write the resigned IPA to the current"
	echo "                  working directory according to the given options:"
	echo "                  bundle-identifier NEW-BUNDLE-IDENTIFIER [optional]"
	echo "                  provisioning-profile NEW-PROVISIONING-PROFILE [required]"
	echo ""
}

extracted_ipa=""

extract_ipa() {
	ipa="$1"
	absipa=`absPath "$ipa"`
	if ( ! test -f "$absipa" ); then
		fatal "$absipa: file not found"
	fi
	extracted_ipa="/tmp/$scriptName.$$"
	mkdir "$extracted_ipa" || fatal "Could not create temp dir"
	pushd . > /dev/null
	cd "$extracted_ipa"
	unzip "$absipa" 2>&1 > /dev/null || fatal "unzip failed"
	popd > /dev/null
}

delete_temps() {
	rm -rf "$extracted_ipa"
}

ipatool_appname() {
	ls "$extracted_ipa/Payload"
}

ipatool_app_path() {
	echo "$extracted_ipa/Payload/`ipatool_appname`"
}

ipatool_bundle_info() {
	/usr/libexec/PlistBuddy -c "Print $1" "`ipatool_app_path`/Info.plist" 2>/dev/null
}

ipatool_device_family() {
	families="`/usr/libexec/PlistBuddy -c \"Print UIDeviceFamily\" \"\`ipatool_app_path\`/Info.plist\" | tail -r -3 | tail -r -2`"
	for f in $families; do
		case $f in
		1)
			echo -n "iphone "
			;;
		2)
			echo -n "ipad "
			;;
		3)
			echo -n "appletv "
			;;
		esac
	done
}

ipatool_codesign_authority() {
	codesign -d -v -v "`ipatool_app_path`" 2>&1 | grep "^Authority=" | head -1 | cut -d '=' -f 2
}

ipatool_provisioning() {
	security cms -D -i "`ipatool_app_path`/embedded.mobileprovision" -o "$extracted_ipa/prov.plist"
	/usr/libexec/PlistBuddy -c "Print $1" "$extracted_ipa/prov.plist"
}

ipatool_info() {
	ipa="$1"
	echo "  App name:            `ipatool_appname`"
	echo "  Display name:        `ipatool_bundle_info CFBundleDisplayName`"
	echo "  Version:             `ipatool_bundle_info CFBundleShortVersionString`"
	echo "  Build:               `ipatool_bundle_info CFBundleVersion`"
	echo "  Bundle identifier:   `ipatool_bundle_info CFBundleIdentifier`"
	echo "  Code sign authority: `ipatool_codesign_authority`"
	echo "  Minimum OS version:  `ipatool_bundle_info MinimumOSVersion`"
	echo "  Device family:       `ipatool_device_family`"
	echo ""
	echo "Provisioning:"
	echo "  Name:                `ipatool_provisioning Name`"
	echo "  Expiration:          `ipatool_provisioning ExpirationDate`"
	echo "  App ID name:         `ipatool_provisioning AppIDName`"
	echo "  Team:                `ipatool_provisioning TeamName`"
}

ipatool_resign() {
	ipa="$1"
	# Start at the first param for the resign command
	shift 3
	newBundle=""
	newProfile=""
	while (( "$#" )); do
		if (test "$1" = "bundle-identifier"); then
			shift
			newBundle="$1"
		elif (test "$1" = "provisioning-profile"); then
			shift
			newProfile="$1"
		fi
		shift
	done
	if (test "$newProfile" = ""); then
		fatal "New provisioning profile is not given on command line."
	fi
	
	absipa=`absPath "$ipa"`
	absprofile="`absPath \"$PWD\"`/$newProfile"
	if ( ! test -f "$absprofile" ); then
		fatal "$absprofile: file not found"
	fi
	keychain="`security default-keychain|sed 's/[ \"]//g'`"
	security show-keychain-info $keychain > /dev/null 2>&1 || security unlock-keychain "$keychain"
	ipatool_resign_execute "$absipa" "$absprofile" "$newBundle" || fatal "resign failed"
	resigned_ipa="`dirname $absipa`/`basename $ipa .ipa`_resigned.ipa"
	mv "$extracted_ipa/resigned.zip" "$resigned_ipa"
	echo "Resigned ipa: $resigned_ipa"
}

ipatool_resign_execute() {
	absipa="$1"
	absprofile="$2"
	bundleId="$3"
	echo "Execute for $absipa $absprofile $bundleId"
	
	AppInternalName="`ipatool_appname`"
	cd "$extracted_ipa/Payload"
	cp "$absprofile" "./$AppInternalName/embedded.mobileprovision"
	export EMBEDDED_PROFILE_NAME=embedded.mobileprovision
	export CODESIGN_ALLOCATE="`xcrun --find codesign_allocate`"
	if ( ! test -x "$CODESIGN_ALLOCATE" ); then
		fatal "Could not find executable codesign_allocate"
	fi

	#Update the Info.plist with the new Bundle ID
	OrgBundleID="`ipatool_bundle_info CFBundleIdentifier`"
	if ( test "$bundleId" != "" -a "$bundleId" != "$OrgBundleID" ); then
		plistutil -i "./$AppInternalName/Info.plist" -o "./$AppInternalName/Info.txt"
		sed 's/>'$OrgBundleID'</>'$BundleID'</' "./$AppInternalName/Info.txt" >"./$AppInternalName/Info.new.txt"
		plistutil -i "./$AppInternalName/Info.new.txt" -o "./$AppInternalName/Info.new.plist"
		mv -f "./$AppInternalName/Info.new.plist" "./$AppInternalName/Info.plist"
		rm -f "./$AppInternalName/Info.txt" "./$AppInternalName/Info.new.txt"
	fi
	
	SigningCertName="`ipatool_extract_signing_authority $absprofile`"
	if ( test "$bundleId" != "" -a "$bundleId" != "$OrgBundleID" ); then
		codesign -f -vv -s "$SigningCertName" -i $bundleId "$AppInternalName" || fatal "codesign failed"
	else
		codesign -f -vv -s "$SigningCertName" "$AppInternalName" || fatal "codesign failed"
	fi

	cd ..
	zip -r -q "$extracted_ipa/resigned.zip" . || fatal "Could not compress new ipa"
}

ipatool_extract_signing_authority() {
	absprofile="$1"
	security cms -D -i "$absprofile" -o "$extracted_ipa/newprov.plist"
	end=`grep -n --binary-files=text '</plist>' "$extracted_ipa/newprov.plist"|cut -d: -f-1`
 	subject="`sed -n \"2,${end}p\" \"$1\"|xpath '//data' 2>/dev/null|sed -e '1d' -e '$d'|base64 -D| openssl x509 -subject -inform der|head -n 1`}"
 	echo $subject | sed 's|^.*CN=\([^/]*\)/.*$|\1|'
}

ipa="$1"
if (test "$1" = ""); then
	usage
	exit 1
fi

command="$2"
if (test "$2" = ""); then
	command="info"
fi

case $command in
info)
	extract_ipa "$ipa" || fatal "Failed to extract IPA"
	ipatool_info "$ipa"
	;;
version)
	extract_ipa "$ipa" || fatal "Failed to extract IPA"
	ipatool_bundle_info CFBundleShortVersionString
	;;
build)
	extract_ipa "$ipa" || fatal "Failed to extract IPA"
	ipatool_bundle_info CFBundleVersion
	;;
resign)
	extract_ipa "$ipa" || fatal "Failed to extract IPA"
	SAVEIFS=$IFS
	IFS=$(echo -en "\n")
	ipatool_resign "$ipa" $*
	IFS=$SAVEIFS
	;;
*)
	fatal "Invalid command $command"
	;;
esac

delete_temps
