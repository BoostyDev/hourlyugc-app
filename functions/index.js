/**
 * Firebase Cloud Functions para HourlyUGC
 * Envía notificaciones push cuando se crean mensajes en el chat
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Inicializar Firebase Admin (se hace automáticamente en Cloud Functions)
if (!admin.apps.length) {
  admin.initializeApp();
}

/**
 * Envía notificación push cuando se crea un nuevo mensaje
 * Trigger: onCreate en messages subcollection
 */
exports.sendChatNotification = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const message = snap.data();
    const { chatId, messageId } = context.params;
    
    const senderId = message.senderId;
    const receiverId = message.receiverId;
    const messageText = message.text || 'Image';
    
    // No enviar notificación si el mensaje es del mismo usuario
    if (!receiverId || senderId === receiverId) {
      return null;
    }
    
    try {
      // Obtener información del remitente
      const senderDoc = await admin.firestore()
        .collection('users')
        .doc(senderId)
        .get();
      
      const senderData = senderDoc.data();
      const senderName = senderData?.fullName || 
                        senderData?.displayName || 
                        senderData?.firstName || 
                        'Someone';
      
      // Obtener token FCM del receptor
      const receiverDoc = await admin.firestore()
        .collection('users')
        .doc(receiverId)
        .get();
      
      const receiverData = receiverDoc.data();
      const fcmToken = receiverData?.fcmToken;
      
      if (!fcmToken) {
        console.log(`No FCM token found for user ${receiverId}`);
        return null;
      }
      
      // Preparar el mensaje de notificación
      const notification = {
        title: senderName,
        body: messageText.length > 100 ? messageText.substring(0, 100) + '...' : messageText,
      };
      
      // Preparar los datos adicionales
      const data = {
        type: 'chat',
        chatId: chatId,
        messageId: messageId,
        senderId: senderId,
        receiverId: receiverId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      };
      
      // Enviar notificación
      const messagePayload = {
        token: fcmToken,
        notification: notification,
        data: {
          ...data,
          // Convertir objetos a strings para FCM
          chatId: String(data.chatId),
          messageId: String(data.messageId),
          senderId: String(data.senderId),
          receiverId: String(data.receiverId),
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'chat_channel',
            sound: 'default',
            priority: 'high',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
              badge: 1,
            },
          },
        },
      };
      
      const response = await admin.messaging().send(messagePayload);
      console.log(`Successfully sent notification to ${receiverId}:`, response);
      
      return response;
    } catch (error) {
      console.error('Error sending notification:', error);
      return null;
    }
  });

/**
 * Envía notificación cuando cambia el estado de una aplicación
 * Trigger: onUpdate en applications collection
 */
exports.sendApplicationStatusNotification = functions.firestore
  .document('applications/{applicationId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    const { applicationId } = context.params;
    
    // Solo notificar si el estado cambió
    if (before.status === after.status) {
      return null;
    }
    
    const applicantId = after.applicantId;
    const jobTitle = after.jobTitle || 'a job';
    const status = after.status;
    
    try {
      // Obtener token FCM del aplicante
      const applicantDoc = await admin.firestore()
        .collection('users')
        .doc(applicantId)
        .get();
      
      const applicantData = applicantDoc.data();
      const fcmToken = applicantData?.fcmToken;
      
      if (!fcmToken) {
        console.log(`No FCM token found for user ${applicantId}`);
        return null;
      }
      
      // Preparar el mensaje según el estado
      let title = 'Application Status Updated';
      let body = `Your application for "${jobTitle}" is now ${status}`;
      
      if (status === 'accepted') {
        title = '🎉 Application Accepted!';
        body = `Congratulations! Your application for "${jobTitle}" has been accepted!`;
      } else if (status === 'rejected') {
        title = 'Application Update';
        body = `Your application for "${jobTitle}" was not selected at this time.`;
      }
      
      // Enviar notificación
      const messagePayload = {
        token: fcmToken,
        notification: {
          title: title,
          body: body,
        },
        data: {
          type: 'application_status',
          applicationId: String(applicationId),
          status: String(status),
          jobTitle: String(jobTitle),
          click_action: 'FLUTTER_NOTIFICATION_CLICK',
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'general_channel',
            sound: 'default',
          },
        },
        apns: {
          headers: {
            'apns-priority': '10',
          },
          payload: {
            aps: {
              sound: 'default',
            },
          },
        },
      };
      
      const response = await admin.messaging().send(messagePayload);
      console.log(`Successfully sent application notification to ${applicantId}:`, response);
      
      return response;
    } catch (error) {
      console.error('Error sending application notification:', error);
      return null;
    }
  });

