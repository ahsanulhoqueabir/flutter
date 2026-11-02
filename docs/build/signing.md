# App signing

Release builds must be signed with **your** key before the stores will accept them. Never commit keys or passwords. The `.gitignore` excludes the usual file types, but double-check before pushing.

## Android

### 1. Create an upload keystore (once per app)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Store the `.jks` file and its passwords in a password manager. If you lose them, you can't publish updates (unless you use Play App Signing, which is strongly recommended).

### 2. Create `android/key.properties` (git-ignored)

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

### 3. Tell Gradle to use it

In `android/app/build.gradle.kts`, add above the `android {` block:

```kotlin
import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Inside `android { ... }`:

```kotlin
signingConfigs {
    create("release") {
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
        storeFile = keystoreProperties["storeFile"]?.let { file(it) }
        storePassword = keystoreProperties["storePassword"] as String
    }
}
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

Replace the existing `signingConfig = signingConfigs.getByName("debug")` line in the `release` block.

### 4. Verify

```bash
flutter build appbundle --release --dart-define-from-file=config/prod.json
```

Make sure `android/key.properties` is ignored: `git check-ignore android/key.properties` should print the path.

## iOS / macOS

Signing is managed in Xcode:

1. Open `ios/Runner.xcworkspace`.
2. Select the **Runner** target → **Signing & Capabilities**.
3. Tick **Automatically manage signing** and pick your Apple Developer team.
4. Make sure the **Bundle Identifier** matches the app you created in App Store Connect.

`flutter build ipa` then signs automatically. For CI, use Fastlane Match or App Store Connect API keys instead of personal certificates.
