## Step 1: Start Metro

First, you will need to run **Metro**, the JavaScript build tool for React Native.

To start the Metro dev server, run the following command from the root of your React Native project:

```sh
# Using npm
npm start

# OR using Yarn
yarn start
```

## Step 2: Build and run application example

With Metro running, open a new terminal window/pane from the root of your React Native project, and use one of the following commands to build and run your Android or iOS app:

### Android

```sh
# Using npm
npm run android

# OR using Yarn
yarn android
```

### iOS

For iOS, remember to install CocoaPods dependencies (this only needs to be run on first clone or after updating native deps).

The first time you create a new project, run the Ruby bundler to install CocoaPods itself:

```sh
bundle install
```

Then, and every time you update your native dependencies, run:

```sh
bundle exec pod install
```

For more information, please visit [CocoaPods Getting Started guide](https://guides.cocoapods.org/using/getting-started.html).

```sh
# Using npm
npm run ios

# OR using Yarn
yarn ios
```

If everything is set up correctly, you should see your new app running in the Android Emulator, iOS Simulator, or your connected device.

This is one way to run your app — you can also build it directly from Android Studio or Xcode.

# Switching React Native Architectures

## Android Architecture Switching

### Enabling the New Architecture (Fabric/TurboModule)

1. Open `android/gradle.properties` and set:

```properties
newArchEnabled=true
```

2. Generate the Codegen artifacts (critical step):

```bash
cd android
./gradlew generateCodegenArtifactsFromSchema
```

3. Rebuild and run:

```bash
npx react-native run-android
```

### Reverting to the Old Architecture

1. Open `android/gradle.properties` and set:

```properties
newArchEnabled=false
```

2. Rebuild and run:

```bash
npx react-native run-android
```

## iOS Architecture Switching

### Enabling the New Architecture (Fabric/TurboModule)

1. Open `ios/Podfile` and make sure the following code exists at the top:

```ruby
ENV['RCT_NEW_ARCH_ENABLED'] = '1'
```

2. Reinstall pods and generate the Codegen artifacts (critical step):

```bash
cd ios
bundle exec pod install
```

3. Reinstall pods and run:

```bash
npx react-native run-ios
```

### Reverting to the Old Architecture

1. Open `ios/Podfile` and change the environment variable:

```ruby
ENV['RCT_NEW_ARCH_ENABLED'] = '0'
```

2. Reinstall pods:

```bash
cd ios
bundle exec pod install
```

3. Run the app:

```bash
npx react-native run-ios
```
