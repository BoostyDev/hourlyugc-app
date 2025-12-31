import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firebase configuration - Optimized for mobile performance
class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    
    // Enable Firestore offline persistence for smooth UX
    await _enableOfflinePersistence();
    
    // Initialize Firebase App Check
    await _initializeAppCheck();
  }
  
  /// Enable offline persistence for faster loads and offline support
  static Future<void> _enableOfflinePersistence() async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Enable offline persistence with unlimited cache
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Firestore persistence error: $e');
      }
    }
  }
  
  /// Initialize Firebase App Check for enhanced security
  static Future<void> _initializeAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        // For Android: Use Play Integrity in production
        androidProvider: kDebugMode 
            ? AndroidProvider.debug 
            : AndroidProvider.playIntegrity,
        // For iOS: Use DeviceCheck in production  
        appleProvider: kDebugMode 
            ? AppleProvider.debug 
            : AppleProvider.deviceCheck,
      );
      
    } catch (e) {
      // App Check errors are normal in development - no logging
    }
  }
}

