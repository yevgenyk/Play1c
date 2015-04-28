# Play1c
Play1c: reusable, hackable starter project for iOS and Android native apps

### Quick Start
Quick Start – The Short Version

Make sure you have Android NDK installed and ndk-build available. The NDK needs to be in the PATH.

git clone https://github.com/yevgenyk/Play1c.git

iOS and OS X
cd ios-search
ios-search.xcodeproj is the iOS project, it should just work

cd app/src/main/jni
tests.xcodeproj is the OS X unit test, set up a new scheme, and point working directory to tests subfolder

Android
1)
cd app/src/main/jni
in terminal, run ndk-build
which will build the native shared libraries used by the android app

2)
cd app
in terminal, run ./gradlew assembleDebug

Optionally enable buildNative command line building by providing a full path to ndk-build inside app’s build.gradle

### Less Quick Start (with pictures)

http://codingsimplicity.com/play1c-reusable-hackable-starter-project-for-ios-and-android-native-apps/

