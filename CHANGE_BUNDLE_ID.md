# Cómo Cambiar el Bundle ID

## ⚠️ Solo hazlo si quieres usar un Bundle ID personalizado

Bundle ID actual: `com.example.hourlyugc`

## Paso 1: Cambiar Bundle ID en iOS

### Método 1: Con Xcode (Recomendado)
1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona "Runner" en el navegador de proyectos
3. En la pestaña "General", encuentra "Bundle Identifier"
4. Cámbialo a tu nuevo Bundle ID (ej: `com.postprofit.hourlyugc`)
5. Guarda los cambios

### Método 2: Manual
Edita `ios/Runner.xcodeproj/project.pbxproj`:

Busca todas las líneas que digan:
```
PRODUCT_BUNDLE_IDENTIFIER = com.example.hourlyugc;
```

Y cámbialas a:
```
PRODUCT_BUNDLE_IDENTIFIER = com.tuempresa.hourlyugc;
```

## Paso 2: Cambiar Package Name en Android

Edita `android/app/build.gradle.kts`:

Busca estas líneas:
```kotlin
namespace = "com.example.hourlyugc"
```
```kotlin
applicationId = "com.example.hourlyugc"
```

Y cámbialas a:
```kotlin
namespace = "com.tuempresa.hourlyugc"
```
```kotlin
applicationId = "com.tuempresa.hourlyugc"
```

## Paso 3: Cambiar estructura de carpetas en Android

1. Renombra las carpetas en:
   ```
   android/app/src/main/kotlin/com/example/hourlyugc/
   ```
   
   A:
   ```
   android/app/src/main/kotlin/com/tuempresa/hourlyugc/
   ```

2. Edita `android/app/src/main/kotlin/com/tuempresa/hourlyugc/MainActivity.kt`:
   ```kotlin
   package com.tuempresa.hourlyugc
   ```

## Paso 4: Actualizar AndroidManifest.xml

Edita `android/app/src/main/AndroidManifest.xml`:

Busca:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.hourlyugc">
```

Cámbialo a:
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.tuempresa.hourlyugc">
```

## Paso 5: Limpiar y Reconstruir

```bash
cd C:\Mobileprofit\hourlyugc
flutter clean
flutter pub get
```

## ✅ Listo!

Ahora usa tu nuevo Bundle ID en Firebase Console.

