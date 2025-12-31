# HourlyUGC - Flutter Setup Guide

## 🚀 Setup Rápido

### 1. Instalar Dependencies

```bash
flutter pub get
```

### 2. Configurar Firebase

#### iOS
1. Ve a Firebase Console: https://console.firebase.google.com/
2. Crea un nuevo proyecto o usa uno existente
3. Agrega una app iOS
4. Descarga `GoogleService-Info.plist`
5. Colócalo en: `ios/Runner/GoogleService-Info.plist`

#### Android
1. En Firebase Console, agrega una app Android
2. Descarga `google-services.json`
3. Colócalo en: `android/app/google-services.json`

#### Configurar FlutterFire CLI (Recomendado)

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase automáticamente
flutterfire configure
```

### 3. Habilitar Servicios de Firebase

En Firebase Console, habilita:
- ✅ Authentication (Google, Apple, Email/Password)
- ✅ Firestore Database
- ✅ Storage
- ✅ Analytics (opcional)

### 4. Configurar Reglas de Firestore

Copia las reglas de `firestore.rules` del proyecto web a Firebase Console:
1. Ve a Firestore Database > Rules
2. Pega el contenido de `firestore.rules`
3. Publica las reglas

### 5. Configurar Storage Rules

Copia las reglas de `storage.rules` del proyecto web a Firebase Console:
1. Ve a Storage > Rules
2. Pega el contenido de `storage.rules`
3. Publica las reglas

### 6. Configurar Autenticación

#### Google Sign-In (iOS)
1. En `ios/Runner/Info.plist`, agrega:
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Copia el REVERSED_CLIENT_ID de GoogleService-Info.plist -->
      <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
    </array>
  </dict>
</array>
```

#### Google Sign-In (Android)
1. En Firebase Console, descarga el `SHA-1` key:
```bash
cd android
./gradlew signingReport
```
2. Agrega el SHA-1 a tu app en Firebase Console

#### Apple Sign-In
1. En Xcode, habilita "Sign in with Apple" capability
2. En Firebase Console, habilita Apple como proveedor

### 7. Correr la App

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android
```

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── config/         # Firebase, env config
│   ├── constants/      # App constants
│   ├── router/         # GoRouter setup
│   ├── theme/          # App theme
│   └── utils/          # Validators, formatters
├── data/
│   ├── models/         # Data models
│   └── repositories/   # Data repositories
└── presentation/
    ├── providers/      # Riverpod providers
    ├── screens/        # All screens
    └── widgets/        # Reusable widgets
```

## 🔑 Funcionalidades Implementadas

### ✅ Autenticación
- Login con Google
- Login con Apple
- Login con Email/Password
- Registro de usuario
- Formulario de registro completo (perfil creator)

### ✅ Creator Dashboard
- Stats (Applications, Saved Jobs, Profile Views)
- Quick actions
- Recent jobs feed

### ✅ Jobs
- Lista de trabajos disponibles
- Búsqueda de trabajos
- Filtros (location, budget)
- Detalles del trabajo
- Aplicar a trabajos con cover letter

### ✅ Applications
- Lista de mis aplicaciones
- Estados: Pending, Accepted, Rejected
- Stats de aplicaciones

### ✅ Chat (Placeholder)
- UI básica
- TODO: Implementar mensajería en tiempo real

### ✅ Payout (Placeholder)
- UI básica de balance
- TODO: Integrar con Stripe

## 🚧 Funcionalidades Pendientes

### Portfolio
- Editor de portfolio
- Upload de imágenes/videos
- Vista pública

### Chat Completo
- Mensajería en tiempo real con Firestore
- Envío de imágenes
- Typing indicators

### Payout Completo
- Integración con Stripe
- Payment methods
- Transaction history

### Notificaciones
- Push notifications con FCM
- Local notifications

## 📱 Testing

```bash
# Run tests
flutter test

# Run on specific device
flutter devices
flutter run -d <device_id>
```

## 🐛 Troubleshooting

### Error: Firebase not initialized
- Verifica que `GoogleService-Info.plist` y `google-services.json` estén en los lugares correctos
- Corre `flutterfire configure` de nuevo

### Error: Google Sign-In no funciona
- Verifica el SHA-1 en Firebase Console (Android)
- Verifica el REVERSED_CLIENT_ID en Info.plist (iOS)

### Error: Firestore permissions denied
- Verifica que las reglas de Firestore estén publicadas correctamente
- Verifica que el usuario esté autenticado

## 📚 Recursos

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
- [Riverpod Documentation](https://riverpod.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)

## 🤝 Contribuir

Este es un proyecto privado. Para agregar funcionalidades:

1. Crea un branch desde `main`
2. Implementa tu feature
3. Haz commit con mensajes descriptivos
4. Crea un Pull Request

## 📄 Licencia

Privado - Todos los derechos reservados

