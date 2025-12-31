# 🤖 Configuración de Android Studio para Flutter

## Paso 1: Abrir SDK Manager

1. Abre **Android Studio**
2. En la pantalla de bienvenida:
   - Click en los **3 puntos verticales** (More Actions)
   - Click en **SDK Manager**

   ![SDK Manager](https://docs.flutter.dev/assets/images/docs/get-started/android/win/android-studio-preferences.png)

---

## Paso 2: Instalar SDK Platforms

En la ventana **SDK Manager**:

1. Ve a la pestaña **SDK Platforms**
2. Marca estas versiones:
   - ✅ **Android 13.0 (Tiramisu)** - API Level 33
   - ✅ **Android 12.0 (S)** - API Level 31

3. Click en **Apply** → **OK**
4. Espera que descargue

---

## Paso 3: Instalar SDK Tools (IMPORTANTE)

1. Ve a la pestaña **SDK Tools**
2. Marca la casilla **"Show Package Details"** (abajo a la derecha)
3. Busca y marca:
   - ✅ **Android SDK Build-Tools** (la versión más reciente)
   - ✅ **Android SDK Command-line Tools (latest)** ← **MUY IMPORTANTE**
   - ✅ **Android Emulator**
   - ✅ **Android SDK Platform-Tools**
   - ✅ **Intel x86 Emulator Accelerator (HAXM installer)** (si tienes Intel)

4. Click en **Apply** → **OK**
5. **Espera que termine de descargar TODO** (puede tardar 10-15 minutos)

---

## Paso 4: Verificar la Ruta del SDK

En la parte superior de **SDK Manager**, verás:

```
Android SDK Location: C:\Users\hait7\AppData\Local\Android\Sdk
```

**Copia esta ruta** - la necesitarás después.

---

## Paso 5: Crear un Emulador Android (AVD)

Una vez que todo esté instalado:

### A) Abrir Device Manager

1. En Android Studio, click en **More Actions** → **Virtual Device Manager**
   
   O ve a: **Tools** > **Device Manager**

### B) Crear Nuevo Dispositivo

1. Click en **Create Device** (botón +)

2. **Seleccionar Hardware:**
   - Categoría: **Phone**
   - Elige: **Pixel 6** o **Pixel 5** (recomendado)
   - Click **Next**

3. **Descargar System Image:**
   - Elige: **Tiramisu** (API Level 33) o **S** (API Level 31)
   - Click en el icono **⬇️ Download** al lado
   - Espera que descargue (3-5 minutos)
   - Click **Next**

4. **Configuración del AVD:**
   - Nombre: Déjalo por defecto (ej: "Pixel 6 API 33")
   - Click **Finish**

### C) Iniciar el Emulador

1. En **Device Manager**, verás tu emulador listado
2. Click en el botón **▶️ (Play)** verde
3. Espera 1-2 minutos a que inicie
4. ¡Listo! Ya tienes Android corriendo

---

## Paso 6: Verificar Configuración de Flutter

Abre PowerShell y ejecuta:

```powershell
C:\flutter\bin\flutter.bat doctor
```

Deberías ver algo como:

```
[√] Flutter
[√] Android toolchain - develop for Android devices
[√] Android Studio
[√] Connected device (1 available)
```

---

## Paso 7: Aceptar Licencias (Después de instalar todo)

```powershell
C:\flutter\bin\flutter.bat doctor --android-licenses
```

Presiona **Y** (yes) para cada licencia que aparezca.

---

## 🚀 Correr la App

Una vez que tengas el emulador corriendo:

```powershell
cd C:\Mobileprofit\hourlyugc
C:\flutter\bin\flutter.bat devices
```

Deberías ver tu emulador listado. Luego corre:

```powershell
C:\flutter\bin\flutter.bat run
```

O desde VS Code:
- Presiona **F5**
- Selecciona tu emulador Android

---

## ❗ Problemas Comunes

### "Android sdkmanager not found"
- **Solución:** Asegúrate de instalar **Android SDK Command-line Tools (latest)** desde SDK Manager

### El emulador no inicia
- **Solución 1:** Habilita virtualización en BIOS
- **Solución 2:** Instala HAXM desde SDK Manager
- **Solución 3:** Si tienes AMD, habilita Hyper-V en Windows

### "Unable to locate Android SDK"
```powershell
C:\flutter\bin\flutter.bat config --android-sdk "C:\Users\hait7\AppData\Local\Android\Sdk"
```

### Flutter no encuentra el emulador
- Asegúrate que el emulador esté corriendo (ventana de Android abierta)
- Ejecuta: `C:\flutter\bin\flutter.bat devices`

---

## 📋 Checklist Final

Antes de correr la app, verifica:

- [ ] Android Studio instalado completamente
- [ ] SDK Platforms descargados (API 31 o 33)
- [ ] SDK Tools instalados (especialmente Command-line Tools)
- [ ] Emulador Android creado
- [ ] Emulador iniciado y corriendo
- [ ] `flutter doctor` no muestra errores de Android
- [ ] Licencias aceptadas

---

## 💡 Tips

1. **El emulador consume recursos** - ciérralo cuando no lo uses
2. **Primera vez es lenta** - el emulador tarda en iniciar la primera vez
3. **Puedes dejarlo abierto** - no lo cierres entre ejecuciones de la app
4. **Hot Reload es tu amigo** - presiona 'r' en la terminal para recargar cambios

---

## 🎉 ¡Listo para Desarrollar!

Una vez completado todo, podrás:
- ✅ Desarrollar en el emulador
- ✅ Usar Hot Reload
- ✅ Probar todas las funcionalidades
- ✅ Ver la app como en un teléfono real

