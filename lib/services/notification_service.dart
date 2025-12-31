import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Top-level function for background messages
/// MUST be a top-level or static function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already initialized
  await Firebase.initializeApp();
  
  // Background message received - no logging to reduce lag
  
  // Initialize local notifications for background messages
  final FlutterLocalNotificationsPlugin localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosSettings = DarwinInitializationSettings();
  const initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );
  
  await localNotifications.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap in background
    },
  );
  
  // Show notification for background message
  if (message.notification != null) {
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }
}

/// Notification Service - Handles all push notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;
  String? _fcmToken;
  
  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );
      
      // Permission status checked
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // Initialize local notifications
        await _initializeLocalNotifications();
        
        // Get FCM token
        await _getFCMToken();
        
        // Setup message handlers
        _setupMessageHandlers();
        
        // Setup token refresh listener
        _messaging.onTokenRefresh.listen(_saveTokenToFirestore);
        
        _initialized = true;
      }
    } catch (e) {
      // Log only critical errors
      if (kDebugMode) {
        debugPrint('NotificationService init error: $e');
      }
    }
  }
  
  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    // Android settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Create notification channels for Android
    await _createNotificationChannels();
  }
  
  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    // Chat channel
    const androidChannel = AndroidNotificationChannel(
      'chat_channel',
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
    
    // General channel
    const generalChannel = AndroidNotificationChannel(
      'general_channel',
      'General Notifications',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }
  
  /// Get FCM token and save to Firestore
  Future<void> _getFCMToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      
      if (_fcmToken != null) {
        await _saveTokenToFirestore(_fcmToken!);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token error: $e');
      }
    }
  }
  
  /// Save FCM token to Firestore
  Future<void> _saveTokenToFirestore(String token) async {
    try {
      // Get current user ID (you'll need to pass this or get it from auth)
      // For now, we'll save it when user logs in
      final firestore = FirebaseFirestore.instance;
      
      // Store token in a collection for later use
      // You should update this to save to user's document
      await firestore.collection('fcm_tokens').doc(token).set({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token save error: $e');
      }
    }
  }
  
  /// Save FCM token for specific user
  Future<void> saveTokenForUser(String userId) async {
    if (_fcmToken == null) {
      await _getFCMToken();
    }
    
    if (_fcmToken != null) {
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(userId).update({
          'fcmToken': _fcmToken,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        if (kDebugMode) {
          debugPrint('FCM token save error: $e');
        }
      }
    }
  }
  
  /// Setup message handlers
  void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // Background messages (handled by top-level function)
    // Already registered in main.dart
    
    // Opened app from notification (when app was terminated)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    
    // Check if app was opened from notification (when app was terminated)
    _checkInitialMessage();
  }
  
  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    // Foreground message received - show notification
    
    // Show local notification
    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Message',
      message.notification?.body ?? '',
      details,
      payload: message.data.toString(),
    );
  }
  
  /// Handle notification open (when app was in background)
  void _handleNotificationOpen(RemoteMessage message) {
    _navigateFromNotification(message.data);
  }
  
  /// Check if app was opened from notification (when app was terminated)
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _messaging.getInitialMessage();
    
    if (initialMessage != null) {
      _navigateFromNotification(initialMessage.data);
    }
  }
  
  /// Navigate to screen based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    // You'll need to use a navigator key or router to navigate
    // For now, this is a placeholder
    // final type = data['type'] as String?;
    // final chatId = data['chatId'] as String?;
    // final jobId = data['jobId'] as String?;
    
    // TODO: Implement navigation using your router
    // Example:
    // if (type == 'chat' && chatId != null) {
    //   navigatorKey.currentState?.pushNamed('/chat', arguments: chatId);
    // } else if (type == 'job' && jobId != null) {
    //   navigatorKey.currentState?.pushNamed('/job', arguments: jobId);
    // }
  }
  
  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Parse payload and navigate
    if (response.payload != null) {
      // TODO: Parse payload and navigate
    }
  }
  
  /// Get current FCM token
  String? get fcmToken => _fcmToken;
  
  /// Delete FCM token (on logout)
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      _fcmToken = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM token delete error: $e');
      }
    }
  }
}

