#!/bin/bash

cd $(dirname $0)

pod install

# XCPretty log is printed to console; original xcode log is saved to xcode.log.
xcodebuild -workspace TestApp.xcworkspace/ -scheme TestApp_Example build -sdk iphonesimulator | tee xcode.log | xcpretty --color --utf

