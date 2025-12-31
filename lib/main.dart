import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'services/notification_service.dart';
import 'presentation/providers/auth_provider.dart';

// Register background message handler
// MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await firebaseMessagingBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await FirebaseConfig.initialize();
  
  // Only setup push notifications on real devices (not simulators)
  // FCM doesn't work on iOS simulators
  try {
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await NotificationService().initialize();
    }
  } catch (e) {
    // Silently handle notification errors (common on simulators)
    debugPrint('Notification setup skipped: $e');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    // Listen to user changes and save FCM token when user is authenticated
    ref.listen<AsyncValue<dynamic>>(currentUserProvider, (previous, next) {
      next.whenData((userModel) {
        if (userModel != null) {
          // Save FCM token for this user (async, no esperamos)
          NotificationService().saveTokenForUser(userModel.uid).catchError((_) {
            // Silent error handling - no logging to reduce lag
          });
        }
      });
    });

    return MaterialApp.router(
      title: 'HourlyUGC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
