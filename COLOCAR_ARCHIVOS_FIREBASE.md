# 📁 Cómo Colocar los Archivos de Firebase

## Para iOS - GoogleService-Info.plist

### Opción 1: Con Xcode (Recomendado)

1. Descarga `GoogleService-Info.plist` de Firebase Console
2. Abre **Xcode**
3. Navega a: `File > Open` 
4. Selecciona: `C:\Mobileprofit\hourlyugc\ios\Runner.xcworkspace`
5. En el panel izquierdo, busca la carpeta **"Runner"**
6. **Arrastra** el archivo `GoogleService-Info.plist` a la carpeta Runner en Xcode
7. Cuando aparezca el diálogo, asegúrate de marcar:
   - ✅ **Copy items if needed**
   - ✅ **Add to targets: Runner**
8. Click en **Finish**

### Opción 2: Manual (Copiar archivo)

1. Descarga `GoogleService-Info.plist` de Firebase Console
2. Copia el archivo manualmente a:
   ```
   C:\Mobileprofit\hourlyugc\ios\Runner\GoogleService-Info.plist
   ```
3. Verifica que esté ahí con:
   ```powershell
   ls C:\Mobileprofit\hourlyugc\ios\Runner\GoogleService-Info.plist
   ```

---

## Para Android - google-services.json

### Muy Fácil - Solo Copiar

1. Descarga `google-services.json` de Firebase Console
2. Copia el archivo a:
   ```
   C:\Mobileprofit\hourlyugc\android\app\google-services.json
   ```
3. Verifica que esté ahí con:
   ```powershell
   ls C:\Mobileprofit\hourlyugc\android\app\google-services.json
   ```

---

## ✅ Verificación Final

Ambos archivos deben estar en estos lugares exactos:

```
hourlyugc/
├── ios/
│   └── Runner/
│       └── GoogleService-Info.plist  ← AQUÍ
└── android/
    └── app/
        └── google-services.json  ← AQUÍ
```

---

## ⚠️ NO Instales el SDK Manualmente

Cuando Firebase Console te muestre opciones como:
- CocoaPods
- Swift Package Manager
- Download ZIP

**IGNÓRALAS** - Flutter ya tiene las dependencias configuradas en `pubspec.yaml`.

Solo necesitas los archivos de configuración (`.plist` y `.json`).

---

## 🎯 Después de Colocar los Archivos

1. En Firebase Console, haz click en **"Next"** o **"Continue to console"**
2. Repite el proceso para Android (descargar google-services.json)
3. Continúa con el resto de la configuración (Firestore, Authentication, etc.)

