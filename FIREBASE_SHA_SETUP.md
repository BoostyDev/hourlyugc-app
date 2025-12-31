# Configuración de SHA-1 y SHA-256 para Firebase Authentication

## Problema
Firebase Phone Authentication requiere que configures las huellas digitales SHA-1 y SHA-256 de tu app en Firebase Console.

## Solución Rápida: Números de Prueba

Para desarrollo, usa números de teléfono de prueba:

1. Firebase Console → Authentication → Sign-in method → Phone
2. Scroll down a "Phone numbers for testing"
3. Añade: `+34611338183` → Código: `123456`

Ahora puedes usar ese número sin recibir SMS reales.

## Solución Completa: Configurar SHA-1/SHA-256

### Paso 1: Obtener SHA-1 y SHA-256

#### Para Debug (Desarrollo):

```bash
cd android
./gradlew signingReport
```

O en Windows:

```powershell
cd android
.\gradlew.bat signingReport
```

Busca en el output algo como:

```
Variant: debug
Config: debug
Store: C:\Users\TU_USUARIO\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX...
SHA1: A1:B2:C3:D4:E5:F6:G7:H8:I9:J0:K1:L2:M3:N4:O5:P6:Q7:R8:S9:T0
SHA-256: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00
```

Copia los valores de **SHA1** y **SHA-256**.

#### Método alternativo (más rápido):

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

En Windows:

```powershell
keytool -list -v -keystore "C:\Users\TU_USUARIO\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

### Paso 2: Añadir a Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Project Settings** (⚙️ arriba a la izquierda)
4. Scroll down hasta **"Your apps"**
5. Selecciona tu app Android
6. En **"SHA certificate fingerprints"**, click **"Add fingerprint"**
7. Pega el SHA-1 y luego el SHA-256 (añade ambos)
8. **Descarga el nuevo `google-services.json`** y reemplaza el que tienes en `android/app/`

### Paso 3: Reiniciar la app

```bash
flutter clean
flutter pub get
flutter run
```

## Verificar configuración

Después de configurar, deberías ver en Firebase Console → Authentication → Sign-in method → Phone que el estado es **"Enabled"** ✅

## Troubleshooting

- **Error 17028**: SHA-1/SHA-256 no configurados → Sigue los pasos de arriba
- **Error 17010**: Proyecto de Firebase incorrecto → Verifica `google-services.json`
- **SMS no llega**: Usa números de prueba para desarrollo

## Para Release (Producción)

Cuando hagas el build de release, necesitarás obtener el SHA-1/SHA-256 de tu keystore de producción:

```bash
keytool -list -v -keystore TU_KEYSTORE.jks -alias TU_ALIAS
```

Y añadirlos también a Firebase Console.

