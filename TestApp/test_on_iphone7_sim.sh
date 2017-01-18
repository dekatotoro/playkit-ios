#!/bin/bash

cd $(dirname $0)

xcodebuild -workspace TestApp.xcworkspace/ -scheme TestApp_Tests test -destination 'platform=iOS Simulator,OS=10.2,name=iPhone 7' | tee xcode.log | xcpretty --color --utf

echo "Original xcode log (bzip2+base64):"
bzip2 < xcode.log | base64
