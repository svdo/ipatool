#!/bin/sh

export DSTROOT=
xcodebuild -workspace ipatool.xcworkspace -scheme ipatool -configuration Release install
if [ -d "$DSTROOT/tmp/ipatool.dst" ]; then
	echo "Copy $DSTROOT/tmp/ipatool.dst/usr/local/bin/ipatool to $DSTROOT/usr/local/bin/ipatool"
	ditto "$DSTROOT/tmp/ipatool.dst/usr/local/bin/ipatool" "$DSTROOT/usr/local/bin/ipatool"
fi

echo
echo "Installed ipatool in $DSTROOT/usr/local/bin"
