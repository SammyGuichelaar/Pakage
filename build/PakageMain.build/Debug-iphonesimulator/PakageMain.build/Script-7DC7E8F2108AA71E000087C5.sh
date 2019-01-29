#!/bin/sh
chmod 6777 /Users/Xuzz/Pakage/build/Debug-iphoneos/Pakage.app/Pakage
platform=/Developer/Platforms/iPhoneOS.platform
allocate=${platform}/Developer/usr/bin/codesign_allocate
export CODESIGN_ALLOCATE=${allocate} 
codesign -fs "iPhone Developer" /Users/Xuzz/Pakage/build/Debug-iphoneos/Pakage.app/Pakage

mv /Users/Xuzz/Pakage/build/Debug-iphoneos/Pakage.app/Pakage  /Users/Xuzz/Pakage/build/Debug-iphoneos/Pakage.app/Pakage_
cp  /Users/Xuzz/Pakage/bootstrap  /Users/Xuzz/Pakage/build/Debug-iphoneos/Pakage.app/Pakage
