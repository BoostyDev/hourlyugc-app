# 🔑 Obtener SHA-1 y SHA-256 Fingerprints

## ⚠️ Problema: Java no encontrado

El comando `gradlew signingReport` requiere Java. Aquí hay 3 métodos alternativos:

---

## 📋 MÉTODO 1: Usar Android Studio (Más Fácil)

### Opción A: Desde Android Studio

1. **Abre Android Studio**
2. **Abre el proyecto** en: `C:\Mobileprofit\hourlyugc\android`
3. **Click derecho en la carpeta** `android` en el árbol del proyecto
4. **Selecciona**: "Open Module Settings" o presiona `F4`
5. **Ve a**: Modules > app > Signing
6. **Verás** los SHA fingerprints ahí

### Opción B: Desde Android Studio Gradle

1. **Abre Android Studio**
2. **Abre el proyecto**: `C:\Mobileprofit\hourlyugc\android`
3. **Click en el panel "Gradle"** (lado derecho)
4. **Navega a**: `hourlyugc > android > app > Tasks > android > signingReport`
5. **Doble click en** `signingReport`
6. **Copia** SHA-1 y SHA-256 del output

---

## 📋 MÉTODO 2: Usar Flutter Doctor

Flutter puede darte información de Java:

```powershell
flutter doctor -v
```

Busca la línea que dice `Java binary at:` y copia la ruta.

Luego ejecuta:

```powershell
$env:JAVA_HOME="RUTA_QUE_COPIASTE"
cd C:\Mobileprofit\hourlyugc\android
.\gradlew signingReport
```

---

## 📋 MÉTODO 3: Usar keytool Directamente

Si tienes keytool instalado:

```powershell
keytool -list -v -keystore C:\Users\hait7\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Busca en el output**:
- `SHA1:` - Este es tu SHA-1
- `SHA256:` - Este es tu SHA-256

---

## 📋 MÉTODO 4: Instalar Java (Si no tienes Android Studio)

1. **Descarga Java 17**: https://adoptium.net/temurin/releases/?version=17
2. **Instala** en `C:\Program Files\Java\jdk-17`
3. **Configura JAVA_HOME**:
   ```powershell
   [System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\jdk-17", [System.EnvironmentVariableTarget]::Machine)
   ```
4. **Reinicia PowerShell**
5. **Ejecuta**:
   ```powershell
   cd C:\Mobileprofit\hourlyugc\android
   .\gradlew signingReport
   ```

---

## 🎯 QUÉ HACER CON LOS SHA FINGERPRINTS

### Una vez que obtengas los valores:

**Ejemplo de output**:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00
```

### Agrégalos a Firebase:

1. **Ve a**: https://console.firebase.google.com/
2. **Proyecto**: `postprofit-a4a46`
3. **⚙️ Project Settings** > Your apps > Android app
4. **Click "Add fingerprint"**
5. **Pega SHA-1** → Save
6. **Click "Add fingerprint"** nuevamente  
7. **Pega SHA-256** → Save
8. **Descarga** el nuevo `google-services.json`
9. **Reemplaza** en: `android\app\google-services.json`
10. **Ejecuta**:
    ```powershell
    flutter clean
    flutter run
    ```

---

## ✅ Verificación

Después de agregar los SHA fingerprints, el error desaparecerá:

❌ **Antes**:
```
This app is not authorized to use Firebase Authentication
```

✅ **Después**:
```
SMS verification code sent successfully
```

---

## 🆘 Si Ningún Método Funciona

Puedes obtener los SHA temporalmente desde el error de Firebase:

1. **Compila y ejecuta la app**
2. **Intenta usar phone auth**
3. **Firebase mostrará el SHA-1 correcto en el error**
4. **Copia ese SHA-1 y agrégalo a Firebase Console**

---

## 📞 Números de Prueba (Mientras configuras)

Para probar sin SMS reales:

1. Firebase Console > Authentication > Sign-in method > Phone
2. Agrega números de prueba:
   - `+1 650-555-1234` → Code: `123456`
   - `+34 611 33 82 82` → Code: `123456`

---

**Recomendación**: Usa el **MÉTODO 1** (Android Studio) si lo tienes instalado. Es el más rápido y confiable.

