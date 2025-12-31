# 🔒 Firebase App Check Setup Guide

Firebase App Check protects your backend resources (Authentication, Firestore, Storage) from abuse by ensuring requests come from your authentic app.

## Current Status

✅ **Code Updated** - App Check is now initialized in `lib/core/config/firebase_config.dart`
⚠️ **Console Setup Required** - You need to configure App Check in Firebase Console

## What Were Those Warnings?

The errors you saw in the terminal:
```
W/LocalRequestInterceptor: Error getting App Check token; using placeholder token instead.
I/PlayCore: IntegrityService : Failed to bind to the service.
```

These are **expected in development** but should be resolved for production.

---

## 🚀 Setup Instructions

### Step 1: Enable App Check in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **postprofit-a4a46**
3. Click on **App Check** in the left sidebar
4. Click **Get started**

### Step 2: Register Your Android App

#### Option A: For Development/Testing (Recommended First)

1. In App Check settings, select your Android app (`com.example.hourlyugc`)
2. Choose **Play Integrity** as the provider
3. Click **Register**
4. **Enable debug mode**:
   - Click on the **overflow menu** (⋮) next to your app
   - Select **Manage debug tokens**
   - Click **Add debug token**
   - Generate a debug token from your app (see below)

#### Get Debug Token from Your App:

Add this temporary code to `main.dart` to get your debug token:

```dart
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  
  // TEMPORARY: Get debug token for development
  if (kDebugMode) {
    final token = await FirebaseAppCheck.instance.getToken();
    print('🔑 App Check Debug Token: $token');
  }
  
  runApp(const ProviderScope(child: MyApp()));
}
```

5. Run the app and copy the token from the console
6. Paste it in Firebase Console > App Check > Manage debug tokens

### Step 3: Enable App Check for Services

In Firebase Console > App Check:

1. **Authentication**
   - Click on **Authentication**
   - Toggle **Enforce** to ON
   - **Warning**: Don't enforce until you've tested thoroughly!

2. **Firestore**
   - Click on **Cloud Firestore**
   - Toggle **Enforce** to ON (after testing)

3. **Storage**
   - Click on **Cloud Storage**
   - Toggle **Enforce** to ON (after testing)

### Step 4: Testing

1. **Development Mode** (Current):
   - App Check uses debug provider
   - Warnings are normal
   - Phone auth will work with placeholder tokens

2. **Production Mode**:
   - Configure Play Integrity provider
   - Get SHA-256 fingerprint of your release key
   - Add it to Firebase Console

---

## 📱 For Production Release

### Android: Configure Play Integrity

1. **Get SHA-256 fingerprint**:
   ```bash
   cd android
   ./gradlew signingReport
   ```

2. **Add to Firebase Console**:
   - Go to Project Settings > Your apps
   - Find your Android app
   - Click **Add fingerprint**
   - Paste the SHA-256 fingerprint

3. **Enable Play Integrity API**:
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Enable **Play Integrity API** for your project

### iOS: Configure DeviceCheck

1. In Firebase Console, register your iOS app
2. App Check will automatically use DeviceCheck (no additional setup needed)

---

## 🧪 Phone Authentication with App Check

According to the [Firebase Phone Auth documentation](https://firebase.google.com/docs/auth/android/phone-auth), App Check is recommended but not required for phone authentication.

### Current Setup:
- ✅ Phone auth will work in development (with warnings)
- ✅ App Check uses debug tokens in `kDebugMode`
- ✅ Automatically switches to Play Integrity in production

### Testing Phone Auth:

1. **Enable Phone Authentication** in Firebase Console:
   - Go to Authentication > Sign-in method
   - Enable **Phone** provider
   - Add test phone numbers if needed (optional)

2. **Add test phone numbers** (for development):
   - Go to Authentication > Sign-in method > Phone
   - Add test phone numbers with verification codes
   - Example: `+1 650-555-1234` with code `123456`

---

## 🔍 Monitoring

Once App Check is enabled:

1. Go to Firebase Console > App Check
2. View **Metrics** to see:
   - Valid requests
   - Invalid requests
   - App Check token usage

---

## ⚠️ Important Notes

### For Development:
- **Keep enforcement disabled** until fully tested
- Use debug tokens for local testing
- Warnings about IntegrityService are normal in emulators

### For Production:
- **Enable enforcement** to protect your backend
- Use Play Integrity (Android) and DeviceCheck (iOS)
- Monitor metrics regularly

### Common Issues:

1. **"Failed to bind to IntegrityService"**
   - Normal in emulators
   - Will work on real devices with Google Play Services

2. **"No AppCheckProvider installed"**
   - Fixed by the code we just added ✅
   - Verify `firebase_app_check` is in `pubspec.yaml`

3. **Phone auth not working**
   - Ensure Phone provider is enabled in Firebase Console
   - Check that App Check enforcement is OFF during testing
   - Verify google-services.json is up to date

---

## 📚 References

- [Firebase App Check Documentation](https://firebase.google.com/docs/app-check)
- [Firebase Phone Authentication (Android)](https://firebase.google.com/docs/auth/android/phone-auth)
- [Play Integrity API](https://developer.android.com/google/play/integrity)

---

## ✅ Checklist

- [x] Added `firebase_app_check` dependency
- [x] Updated `firebase_config.dart` with App Check initialization
- [ ] Enable App Check in Firebase Console
- [ ] Register Android app with Play Integrity
- [ ] Add debug token for development
- [ ] Enable Phone Authentication provider
- [ ] Test phone auth in development
- [ ] Configure production signing keys
- [ ] Enable App Check enforcement (production only)

---

**Next Steps:**
1. Run `flutter pub get` to install the new dependency
2. Follow the setup instructions above
3. Test phone authentication in your app
4. The warnings will disappear once App Check is properly configured!

