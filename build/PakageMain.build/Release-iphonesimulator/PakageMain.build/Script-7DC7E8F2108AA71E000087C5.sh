#!/bin/sh
chmod 6777 /Users/Xuzz/Desktop/PakageMain/build/Debug-iphoneos/Pakage.app/Pakage
platform=/Developer/Platforms/iPhoneOS.platform
allocate=${platform}/Developer/usr/bin/codesign_allocate
export CODESIGN_ALLOCATE=${allocate} 
codesign -fs "iPhone Developer" /Users/Xuzz/Desktop/PakageMain/build/Debug-iphoneos/Pakage.app/Pakage
