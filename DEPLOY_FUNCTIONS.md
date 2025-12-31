# 🚀 Desplegar Cloud Functions para Notificaciones

Este documento explica cómo desplegar las Cloud Functions para que las notificaciones push funcionen cuando la app está cerrada.

## 📋 Requisitos Previos

1. **Node.js 18+** instalado
2. **Firebase CLI** instalado:
   ```bash
   npm install -g firebase-tools
   ```
3. **Cuenta de Firebase** con el proyecto configurado

## 🔧 Pasos para Desplegar

### 1. Inicializar Firebase Functions (si no está hecho)

```bash
cd hourlyugc
firebase init functions
```

Cuando te pregunte:
- ✅ Selecciona "JavaScript" como lenguaje
- ✅ No instales ESLint (o sí, según prefieras)
- ✅ Instala dependencias ahora

### 2. Instalar Dependencias

```bash
cd functions
npm install
```

### 3. Verificar la Configuración

Asegúrate de que `functions/index.js` contiene las funciones de notificación.

### 4. Desplegar las Functions

```bash
# Desde la carpeta hourlyugc
firebase deploy --only functions
```

O para desplegar solo una función específica:

```bash
firebase deploy --only functions:sendChatNotification
firebase deploy --only functions:sendApplicationStatusNotification
```

### 5. Verificar el Despliegue

Ve a la consola de Firebase:
1. Abre [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a "Functions" en el menú lateral
4. Deberías ver las funciones desplegadas:
   - `sendChatNotification`
   - `sendApplicationStatusNotification`

## 🧪 Probar las Functions

### Opción 1: Probar desde la App

1. Abre la app en dos dispositivos diferentes (o un dispositivo y un emulador)
2. Inicia sesión con dos usuarios diferentes
3. Envía un mensaje desde un usuario al otro
4. El otro usuario debería recibir una notificación push

### Opción 2: Probar desde Firebase Console

1. Ve a Firestore Database
2. Crea manualmente un mensaje en `chats/{chatId}/messages/{messageId}`
3. La función debería ejecutarse automáticamente

### Opción 3: Ver Logs

```bash
firebase functions:log
```

O desde Firebase Console:
1. Ve a Functions
2. Click en una función
3. Ve a la pestaña "Logs"

## 🔍 Troubleshooting

### Error: "Permission denied"

**Solución**: Asegúrate de que las reglas de Firestore permitan a las Cloud Functions leer/escribir:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow Cloud Functions to read/write
    match /{document=**} {
      allow read, write: if request.auth != null || 
        request.auth == null; // Functions run as admin
    }
  }
}
```

### Error: "FCM token not found"

**Solución**: 
1. Verifica que el token FCM se esté guardando en Firestore
2. Verifica que el campo sea `fcmToken` en el documento del usuario
3. Revisa los logs de la función para ver qué está pasando

### Las notificaciones no llegan

**Solución**:
1. Verifica que las Functions estén desplegadas correctamente
2. Verifica que el token FCM sea válido
3. Revisa los logs de Firebase Functions
4. En Android, verifica que la app no esté en modo "Battery Saver"
5. En iOS, verifica que APNs esté configurado correctamente

### Error al desplegar

**Solución**:
1. Verifica que tengas Node.js 18+ instalado
2. Verifica que tengas permisos en Firebase
3. Intenta desplegar desde la carpeta raíz del proyecto

## 📝 Notas Importantes

1. **Costo**: Las Cloud Functions tienen un plan gratuito generoso, pero revisa los límites
2. **Latencia**: Las notificaciones pueden tardar 1-2 segundos en llegar
3. **Tokens**: Los tokens FCM pueden cambiar, por eso se actualizan automáticamente
4. **Testing**: Usa el emulador local para probar antes de desplegar:
   ```bash
   firebase emulators:start --only functions
   ```

## 🔄 Actualizar Functions

Cuando hagas cambios en `functions/index.js`:

```bash
cd hourlyugc
firebase deploy --only functions
```

## 📚 Recursos

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [FCM Admin SDK](https://firebase.google.com/docs/cloud-messaging/admin/send-messages)
- [Firebase Functions Pricing](https://firebase.google.com/pricing)

