# Firebase iOS Configuration Guide

## Overview

This guide explains how to configure Firebase for iOS builds in your Flutter POS app, ensuring it works correctly when building via Codemagic CI/CD.

## Current Status

✅ **Android**: Firebase configured with `google-services.json`  
❌ **iOS**: Missing `GoogleService-Info.plist` file

## Step 1: Get GoogleService-Info.plist from Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **smart-pos-7c76c**
3. Click the gear icon ⚙️ > **Project settings**
4. Scroll down to **Your apps** section
5. If you don't see an iOS app:
   - Click **Add app** > **iOS**
   - **Bundle ID**: `com.example.pos` (must match your iOS app bundle ID)
   - **App nickname**: Smart POS iOS (optional)
   - Click **Register app**
6. Download the `GoogleService-Info.plist` file
7. **Place it in**: `ios/Runner/GoogleService-Info.plist`

## Step 2: Update AppDelegate.swift

The AppDelegate needs to import and configure Firebase. Update `ios/Runner/AppDelegate.swift`:

```swift
import Flutter
import UIKit
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Configure Firebase
    FirebaseApp.configure()
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Note**: The `import FirebaseCore` and `FirebaseApp.configure()` are automatically handled by FlutterFire when you use the Firebase Flutter plugins. The above code is optional but explicit.

## Step 3: Verify Xcode Project Configuration

The FlutterFire plugins should automatically configure your Xcode project, but verify:

1. Open `ios/Runner.xcworkspace` in Xcode (NOT .xcodeproj)
2. In the Project Navigator, verify `GoogleService-Info.plist` is in the Runner folder
3. Select the file and check **Target Membership** includes "Runner"

## Step 4: Configure for Codemagic CI/CD

### Option A: Using FlutterFire CLI (Recommended)

Codemagic can run FlutterFire CLI during the build process:

**codemagic.yaml** configuration:

```yaml
workflows:
  ios-workflow:
    name: iOS Workflow
    environment:
      vars:
        FIREBASE_PROJECT_ID: "smart-pos-7c76c"
      flutter: stable
      xcode: latest
      cocoapods: default
    scripts:
      - name: Get Flutter dependencies
        script: flutter pub get
      
      - name: Configure Firebase
        script: |
          # Install FlutterFire CLI
          dart pub global activate flutterfire_cli
          
          # Configure Firebase (requires FIREBASE_TOKEN environment variable)
          flutterfire configure \
            --project=$FIREBASE_PROJECT_ID \
            --platforms=ios \
            --ios-bundle-id=com.example.pos \
            --yes
      
      - name: Build iOS
        script: |
          flutter build ios --release --no-codesign
    artifacts:
      - build/ios/iphoneos/*.app
```

### Option B: Store GoogleService-Info.plist as Environment Variable

If you prefer not to run FlutterFire CLI on every build:

1. **In Codemagic**:
   - Go to your app settings
   - Navigate to **Environment variables**
   - Add a new variable:
     - **Name**: `GOOGLE_SERVICE_INFO_PLIST`
     - **Value**: Base64-encoded content of your `GoogleService-Info.plist`
     - **Secure**: ✅ (check this box)

2. **Get Base64 value** (run locally):
   ```bash
   # macOS/Linux
   base64 ios/Runner/GoogleService-Info.plist
   
   # Windows PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("ios/Runner/GoogleService-Info.plist"))
   ```

3. **Update codemagic.yaml**:
   ```yaml
   scripts:
     - name: Decode Firebase config
       script: |
         echo $GOOGLE_SERVICE_INFO_PLIST | base64 --decode > ios/Runner/GoogleService-Info.plist
     
     - name: Build iOS
       script: flutter build ios --release --no-codesign
   ```

### Option C: Use Codemagic's Firebase Integration

Codemagic has built-in Firebase integration:

1. In Codemagic, go to your app
2. Navigate to **Integrations** > **Firebase**
3. Connect your Firebase project
4. Codemagic will automatically handle Firebase configuration files

## Step 5: Update .gitignore

Make sure Firebase config files are in `.gitignore`:

```gitignore
# Firebase
ios/Runner/GoogleService-Info.plist
android/app/google-services.json
lib/firebase_options.dart
```

**Important**: Never commit these files to public repositories!

## Step 6: Test Locally (if on macOS)

```bash
# Get dependencies
flutter pub get

# Run on iOS simulator
flutter run -d ios

# Build for iOS
flutter build ios --release
```

## Verification Checklist

Before pushing to Codemagic:

- [ ] `GoogleService-Info.plist` exists in `ios/Runner/`
- [ ] File is added to Xcode project with Runner target
- [ ] `firebase_options.dart` is properly configured
- [ ] Firebase config files are in `.gitignore`
- [ ] Codemagic environment variables are set (if using Option B)
- [ ] `codemagic.yaml` includes Firebase configuration step

## Troubleshooting

### Error: "FirebaseApp.configure() failed"

**Solution**: Verify `GoogleService-Info.plist` is in the correct location and properly formatted.

### Error: "No such module 'FirebaseCore'"

**Solution**: 
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
```

### Codemagic build fails with Firebase error

**Solution**: 
- Check that environment variables are set correctly
- Verify the Firebase project ID matches
- Ensure the iOS bundle ID matches what's registered in Firebase

## Additional Resources

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Codemagic Flutter Firebase Guide](https://docs.codemagic.io/yaml-quick-start/building-a-flutter-app/)
- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)

## Summary

Your Flutter app uses FlutterFire, which is the recommended approach. The key steps are:

1. ✅ Add `GoogleService-Info.plist` to `ios/Runner/`
2. ✅ Configure Codemagic to handle Firebase credentials securely
3. ✅ Keep config files out of version control

The AppDelegate code you mentioned is for native iOS apps. For Flutter apps with FlutterFire, the Firebase initialization is handled automatically by the plugins when you call `Firebase.initializeApp()` in your Dart code (which you're already doing in `main.dart`).
