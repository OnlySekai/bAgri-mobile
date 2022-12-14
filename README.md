CarePlus

# 1. Config
## API env
> config.dart
## Google Map Key
**Android**
Specify your API key in the application manifest *`android/app/src/main/AndroidManifest.xml`*:
```
android:name="com.google.android.geo.API_KEY"
               android:value="YOUR KEY HERE"/>
```
**iOS**
Specify your API key in the application delegate *`ios/Runner/AppDelegate.swift`*:
```
GMSServices.provideAPIKey("YOUR KEY HERE")
```
# 2. Run app
Edit configurations
![](https://i.imgur.com/LpMKEzj.jpg)

# Build Android
Run command before build
```
flutter pub get
flutter pub run intl_utils:generate
flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --release --flavor bag
```
Build APK
Step 1:
![](https://i.imgur.com/8ap2r5O.png)
Step 2:
![](https://i.imgur.com/4rxCQ6g.png)
Step 3:
![](https://i.imgur.com/cbXHZ8X.png)

# Build iOS
Run command before build
```
flutter pub run intl_utils:generate
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter build ios --release --flavor bag
```
Upload TestFlight
Step 1: Confige scheme
![](https://i.imgur.com/g5pSUE5.png)
Step 2: Archive and Upload