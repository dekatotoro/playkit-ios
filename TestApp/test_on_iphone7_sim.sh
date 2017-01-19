#!/bin/bash

cd $(dirname $0)

DESTINATION="platform=iOS Simulator,OS=10.2,name=iPhone 7"
if [ "$TRAVIS" == "true" ]; then
    # Workaround for travis-ci/travis-ci#7031 -- remove this entire if-fi when they fix it.
    DESTINATION="$DESTINATION,id=22FA2149-1241-469C-BF6D-462D3837DB72"
fi

xcodebuild -workspace TestApp.xcworkspace/ -scheme TestApp_Tests test -destination "$DESTINATION" | tee xcode.log | xcpretty --color --utf

echo "Original xcode log (bzip2+base64):"
bzip2 < xcode.log | base64
