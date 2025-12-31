# 🔐 FIX: App Not Authorized - SHA Fingerprints

## ❌ Error Actual

```
E/FirebaseAuth: This app is not authorized to use Firebase Authentication. 
Please verify that the correct package name, SHA-1, and SHA-256 are configured in the Firebase Console.
```

## 🎯 Causa del Problema

Firebase requiere que registres las **huellas digitales SHA-1 y SHA-256** de tu app para autorizar:
- Phone Authentication
- Google Sign-In
- Otras funciones de autenticación

**El código está correcto** ✅ - solo falta configuración en Firebase Console.

---

## 🚀 SOLUCIÓN RÁPIDA (3 Pasos)

### Paso 1: Obtener SHA-1 y SHA-256

Abre una terminal en Windows PowerShell y ejecuta:

```powershell
cd C:\Mobileprofit\hourlyugc\android
.\gradlew signingReport
```

**Busca en el output** la sección `Task :app:signingReport` bajo **Variant: debug**:

```
Variant: debug
Config: debug
Store: C:\Users\hait7\.android\debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX:XX
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00
```

**Copia ambos valores**: SHA1 y SHA-256

---

### Paso 2: Agregar a Firebase Console

1. **Ve a Firebase Console**: https://console.firebase.google.com/
2. **Selecciona tu proyecto**: `postprofit-a4a46` (project ID: 586195135805)
3. **Ve a Project Settings** (⚙️ en la barra lateral)
4. **Baja hasta "Your apps"**
5. **Encuentra tu app Android**: `com.example.hourlyugc`
6. **Click en "Add fingerprint"** (Agregar huella digital)
7. **Pega el SHA-1** y haz click en "Save"
8. **Click en "Add fingerprint"** nuevamente
9. **Pega el SHA-256** y haz click en "Save"

---

### Paso 3: Descargar nuevo google-services.json

1. Después de agregar los SHA fingerprints
2. **Descarga el nuevo `google-services.json`**:
   - En Firebase Console > Project Settings > Your apps
   - Click en el ícono de Android
   - Click en "Download google-services.json"
3. **Reemplaza** el archivo en: `C:\Mobileprofit\hourlyugc\android\app\google-services.json`

---

### Paso 4: Reiniciar App

```powershell
# En la terminal donde está corriendo flutter
# Presiona 'q' para salir

# Luego ejecuta:
flutter clean
flutter run
```

---

## 📋 Verificación

Después de completar los pasos, deberías ver:

✅ **Sin errores** de "app not authorized"
✅ **Phone authentication funcionando**
✅ Código de verificación enviado correctamente

---

## 🔍 Información del Debug Token (Para App Check)

**Tu Debug Token**: `36bf3b58-94a9-4978-9bc4-1568dc0deb9e`

Para configurar App Check (opcional, para producción):

1. Ve a Firebase Console > App Check
2. Click en "Register debug token"
3. Pega: `36bf3b58-94a9-4978-9bc4-1568dc0deb9e`
4. Habilita la API de App Check visitando:
   https://console.developers.google.com/apis/api/firebaseappcheck.googleapis.com/overview?project=586195135805

---

## ⚠️ Errores Relacionados

### Error 1: App Check API Disabled (Línea 173, 226)
```
Firebase App Check API has not been used in project 586195135805 before or it is disabled.
```

**Solución**:
1. Visita: https://console.developers.google.com/apis/api/firebaseappcheck.googleapis.com/overview?project=586195135805
2. Click en "Enable API"
3. Espera 2-3 minutos para que se propague

**Nota**: Phone auth funcionará incluso sin App Check habilitado (usará placeholder tokens).

### Error 2: IntegrityService Failed (Línea 220, 224)
```
IntegrityService : Failed to bind to the service.
```

**Status**: ⚠️ **Normal en emuladores**
- Funciona correctamente en dispositivos físicos con Google Play Services
- Puedes ignorar este error en desarrollo

### Error 3: SMS Verification Failed (Línea 228)
```
SMS verification code request failed: unknown status code: 17028
```

**Causa**: Falta configurar SHA fingerprints (ver pasos arriba)
**Solución**: Completa Paso 1, 2 y 3

---

## 🧪 Testing con Números de Prueba (Opcional)

Para evitar enviar SMS reales durante desarrollo:

1. Ve a Firebase Console > Authentication > Sign-in method
2. Click en "Phone" provider
3. Scroll down hasta "Phone numbers for testing"
4. Agrega números de prueba, ejemplo:
   - Phone: `+34 611 33 82 82`
   - Code: `123456`

Ahora cuando uses ese número, no enviará SMS real y aceptará el código `123456`.

---

## 📚 Referencias

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Phone Authentication Setup](https://firebase.google.com/docs/auth/android/phone-auth)
- [SHA Fingerprint Guide](https://developers.google.com/android/guides/client-auth)

---

## ✅ Checklist de Resolución

- [ ] Ejecutar `gradlew signingReport`
- [ ] Copiar SHA-1 y SHA-256
- [ ] Agregar ambos fingerprints en Firebase Console
- [ ] Descargar nuevo google-services.json
- [ ] Reemplazar archivo en android/app/
- [ ] Ejecutar `flutter clean`
- [ ] Ejecutar `flutter run`
- [ ] Probar phone authentication
- [ ] (Opcional) Habilitar App Check API
- [ ] (Opcional) Agregar debug token para App Check
- [ ] (Opcional) Configurar números de prueba

---

**Tiempo estimado**: 5-10 minutos

**Próximo paso**: Ejecuta el comando `gradlew signingReport` en la siguiente sección.

