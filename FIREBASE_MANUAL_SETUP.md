# 🔥 Configuración Manual de Firebase

## Paso 1: Acceder a Firebase Console

1. Ve a: https://console.firebase.google.com/
2. Inicia sesión con tu cuenta de Google
3. Crea un nuevo proyecto o usa uno existente

## Paso 2: Configurar Firestore

1. En el menú lateral, ve a **Firestore Database**
2. Click en **Crear base de datos**
3. Selecciona **Modo de producción**
4. Elige la ubicación (recomendado: us-central)
5. Click en **Habilitar**

### Configurar Reglas de Firestore

1. Ve a la pestaña **Reglas**
2. Copia TODO el contenido del archivo `firestore.rules` del proyecto web
3. Pégalo en el editor de reglas
4. Click en **Publicar**

## Paso 3: Configurar Storage

1. En el menú lateral, ve a **Storage**
2. Click en **Comenzar**
3. Acepta las reglas predeterminadas
4. Click en **Listo**

### Configurar Reglas de Storage

1. Ve a la pestaña **Reglas**
2. Copia TODO el contenido del archivo `storage.rules` del proyecto web
3. Pégalo en el editor de reglas
4. Click en **Publicar**

## Paso 4: Habilitar Autenticación

1. En el menú lateral, ve a **Authentication**
2. Click en **Comenzar**
3. Ve a la pestaña **Sign-in method**

### Habilitar proveedores:

#### A) Email/Password
1. Click en **Correo electrónico/contraseña**
2. Activa el toggle
3. Guarda

#### B) Google
1. Click en **Google**
2. Activa el toggle
3. Selecciona tu correo de asistencia
4. Guarda

#### C) Apple (Solo para iOS)
1. Click en **Apple**
2. Activa el toggle
3. Guarda

## Paso 5: Configurar Android

### A) Registrar App Android

1. En la página principal del proyecto, click en **icono de Android** (robot)
2. Completa los campos:
   - **Nombre del paquete Android**: `com.example.hourlyugc`
   - **Sobrenombre (opcional)**: HourlyUGC
   - **SHA-1**: (déjalo vacío por ahora, lo agregarás después)
3. Click en **Registrar app**
4. **Descarga google-services.json**
5. Colócalo en: `android/app/google-services.json`

### B) Obtener SHA-1 (Para Google Sign-In)

Abre una terminal y ejecuta:

```bash
cd android
./gradlew signingReport
```

En Windows con PowerShell:
```powershell
cd android
.\gradlew.bat signingReport
```

Busca en el output algo como:
```
SHA1: 1A:2B:3C:4D:... (copia este valor)
```

Luego:
1. Ve a **Configuración del proyecto** (icono de engranaje)
2. Ve a la pestaña **General**
3. Encuentra tu app Android
4. Click en **Agregar huella digital**
5. Pega el SHA-1
6. Guarda

## Paso 6: Configurar iOS

### A) Registrar App iOS

1. En la página principal del proyecto, click en **icono de iOS** (manzana)
2. Completa los campos:
   - **ID del paquete de iOS**: `com.example.hourlyugc`
   - **Sobrenombre (opcional)**: HourlyUGC
3. Click en **Registrar app**
4. **Descarga GoogleService-Info.plist**
5. Colócalo en: `ios/Runner/GoogleService-Info.plist`

### B) Configurar URL Schemes (Para Google Sign-In)

1. Abre el archivo `GoogleService-Info.plist` que acabas de descargar
2. Busca el valor de `REVERSED_CLIENT_ID` (algo como: `com.googleusercontent.apps.123456789-abc...`)
3. Abre `ios/Runner/Info.plist`
4. Agrega esto ANTES de la última etiqueta `</dict>`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Pega aquí el REVERSED_CLIENT_ID -->
      <string>com.googleusercontent.apps.XXXXXXXXX-XXXXXXXXXXXX</string>
    </array>
  </dict>
</array>
```

## Paso 7: Actualizar configuración en el código

### Opción A: Usar FlutterFire

Si quieres generarlo automáticamente (necesitas Dart en PATH):

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

### Opción B: Configuración Manual

Edita `lib/core/config/firebase_config.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "TU_ANDROID_API_KEY",
          appId: "TU_ANDROID_APP_ID",
          messagingSenderId: "TU_SENDER_ID",
          projectId: "TU_PROJECT_ID",
          storageBucket: "TU_STORAGE_BUCKET",
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "TU_IOS_API_KEY",
          appId: "TU_IOS_APP_ID",
          messagingSenderId: "TU_SENDER_ID",
          projectId: "TU_PROJECT_ID",
          storageBucket: "TU_STORAGE_BUCKET",
          iosClientId: "TU_IOS_CLIENT_ID",
          iosBundleId: "com.example.hourlyugc",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  }
}
```

**Los valores los obtienes de:**
1. Ve a Configuración del proyecto (⚙️)
2. Baja hasta la sección de tu app
3. Click en "Config" o los iconos de código
4. Copia los valores

## Paso 8: Verificar instalación

```bash
cd C:\Mobileprofit\hourlyugc
flutter pub get
flutter run
```

Si ves errores de Firebase, verifica:
- ✅ `google-services.json` está en `android/app/`
- ✅ `GoogleService-Info.plist` está en `ios/Runner/`
- ✅ Las reglas de Firestore y Storage están publicadas
- ✅ La autenticación está habilitada

## 🎉 ¡Listo!

Una vez completados estos pasos, tu app debería conectarse correctamente a Firebase.

## Troubleshooting

### Error: "Default FirebaseApp is not initialized"
- Verifica que los archivos de configuración estén en los lugares correctos
- Reinicia el emulador/dispositivo

### Error: "API key not valid"
- Verifica que copiaste correctamente el API key
- Asegúrate de usar el API key correcto para cada plataforma

### Google Sign-In no funciona (Android)
- Verifica que agregaste el SHA-1 a Firebase Console
- Descarga nuevamente `google-services.json` después de agregar el SHA-1

### Google Sign-In no funciona (iOS)
- Verifica el REVERSED_CLIENT_ID en Info.plist
- Asegúrate de que coincida con el de GoogleService-Info.plist

