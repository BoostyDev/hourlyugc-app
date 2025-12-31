# Configuración de Notificaciones Push

Este documento explica cómo funciona el sistema de notificaciones push implementado.

## ✅ Características Implementadas

### 1. Notificaciones en Foreground (App abierta)
- Cuando la app está abierta y recibes un mensaje, se muestra una notificación local
- Funciona automáticamente

### 2. Notificaciones en Background (App en segundo plano)
- Cuando la app está en segundo plano y recibes un mensaje, se muestra una notificación
- Funciona automáticamente

### 3. Notificaciones cuando la App está Cerrada
- **IMPORTANTE**: Para que funcione cuando la app está completamente cerrada, necesitas configurar Firebase Cloud Messaging (FCM) en el backend
- El handler de background está configurado y funcionará cuando recibas mensajes desde el servidor

## 📱 Configuración Requerida

### 1. Cloud Functions (✅ Ya Creadas)

Las Cloud Functions ya están creadas en `functions/index.js`. Solo necesitas desplegarlas:

```bash
cd hourlyugc
firebase deploy --only functions
```

Ver `DEPLOY_FUNCTIONS.md` para instrucciones detalladas.

### 2. Backend Alternativo (Si no usas Cloud Functions)

Si prefieres usar tu propio servidor, necesitas enviar notificaciones push cuando se crea un nuevo mensaje. Ejemplo:

```javascript
// Firebase Functions example
const functions = require('firebase-functions');
const admin = require('firebase-admin');

exports.sendChatNotification = functions.firestore
  .document('messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const receiverId = message.receiverId;
    
    // Get receiver's FCM token
    const receiverDoc = await admin.firestore()
      .collection('users')
      .doc(receiverId)
      .get();
    
    const fcmToken = receiverDoc.data()?.fcmToken;
    
    if (!fcmToken) return;
    
    // Send notification
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: 'New Message',
        body: message.text || 'You have a new message',
      },
      data: {
        type: 'chat',
        chatId: message.chatId,
        senderId: message.senderId,
      },
      android: {
        priority: 'high',
      },
      apns: {
        headers: {
          'apns-priority': '10',
        },
      },
    });
  });
```

### 2. Guardar FCM Token del Usuario

El servicio de notificaciones guarda automáticamente el token FCM. Para guardarlo en el documento del usuario:

```dart
// En tu código de autenticación, después de login:
final notificationService = NotificationService();
await notificationService.saveTokenForUser(userId);
```

## 🔧 Archivos Modificados

1. **`lib/services/notification_service.dart`**: Servicio completo de notificaciones
2. **`lib/main.dart`**: Inicialización del servicio y registro del background handler
3. **`pubspec.yaml`**: Agregado `flutter_local_notifications`

## 🧪 Probar Notificaciones

### 1. Probar en Foreground
- Abre la app
- Envía un mensaje desde otro dispositivo/usuario
- Deberías ver la notificación

### 2. Probar en Background
- Abre la app y luego minimízala (no la cierres completamente)
- Envía un mensaje desde otro dispositivo/usuario
- Deberías ver la notificación

### 3. Probar cuando App está Cerrada
- Cierra completamente la app (swipe away)
- Envía un mensaje desde otro dispositivo/usuario
- **Nota**: Esto requiere que el backend envíe la notificación push

## 📝 Notas Importantes

1. **Android**: Las notificaciones funcionan automáticamente cuando la app está cerrada si el backend envía la notificación push.

2. **iOS**: Requiere configuración adicional:
   - Agregar capabilities en Xcode: Push Notifications y Background Modes
   - Configurar APNs en Firebase Console
   - Obtener el certificado APNs de Apple Developer

3. **Permisos**: El servicio solicita permisos automáticamente al inicializarse.

4. **Tokens**: Los tokens FCM se guardan automáticamente en Firestore cuando el usuario inicia sesión.

## 🐛 Troubleshooting

### Las notificaciones no aparecen cuando la app está cerrada

1. Verifica que el backend esté enviando notificaciones push
2. Verifica que el token FCM esté guardado en Firestore
3. Verifica los logs de Firebase Functions (si usas Functions)
4. En Android, verifica que la app no esté en modo "Battery Saver" que puede bloquear notificaciones

### Las notificaciones no aparecen en iOS

1. Verifica que hayas configurado APNs en Firebase Console
2. Verifica que hayas agregado las capabilities en Xcode
3. Verifica que el certificado APNs esté válido

### El token FCM no se guarda

1. Verifica que el usuario esté autenticado
2. Verifica los permisos de Firestore
3. Revisa los logs de la consola para errores

## 📚 Recursos

- [Firebase Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [Firebase Messaging Flutter](https://firebase.flutter.dev/docs/messaging/overview)

