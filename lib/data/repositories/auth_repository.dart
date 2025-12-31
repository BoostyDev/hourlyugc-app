import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

/// Authentication repository
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  String? _verificationId;
  int? _resendToken;

  /// Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Login with Google
  Future<AuthResult> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult(
          success: false,
          needsRegistration: false,
          error: 'Sign in cancelled',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if user exists and has completed registration
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      final needsRegistration = !userDoc.exists ||
          userDoc.data()?['userType'] == null ||
          !(userDoc.data()?['registrationCompleted'] as bool? ?? false);

      // Create initial user document if it doesn't exist
      // MUST include 'email' and 'userType' to satisfy security rules
      if (!userDoc.exists && userCredential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email ?? googleUser.email,
              'userType': 'genz', // Default to creator, required by security rules
              'firstName': googleUser.displayName?.split(' ').first ?? '',
              'lastName': googleUser.displayName?.split(' ').skip(1).join(' ') ?? '',
              'profileImage': googleUser.photoUrl,
              'registrationCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
              'authProvider': 'google',
            }, SetOptions(merge: true));
      }

      return AuthResult(
        success: true,
        needsRegistration: needsRegistration,
        user: userCredential.user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        needsRegistration: false,
        error: e.toString(),
      );
    }
  }

  /// Login with Apple
  Future<AuthResult> loginWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);

      // Check if user exists
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      final needsRegistration = !userDoc.exists ||
          userDoc.data()?['userType'] == null ||
          !(userDoc.data()?['registrationCompleted'] as bool? ?? false);

      // Create initial user document if it doesn't exist
      // MUST include 'email' and 'userType' to satisfy security rules
      if (!userDoc.exists && userCredential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email ?? appleCredential.email ?? '',
              'userType': 'genz', // Default to creator, required by security rules
              'firstName': appleCredential.givenName ?? '',
              'lastName': appleCredential.familyName ?? '',
              'registrationCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
              'authProvider': 'apple',
            }, SetOptions(merge: true));
      }

      return AuthResult(
        success: true,
        needsRegistration: needsRegistration,
        user: userCredential.user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        needsRegistration: false,
        error: e.toString(),
      );
    }
  }

  /// Login with email and password
  Future<AuthResult> loginWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check registration status
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      final needsRegistration = !userDoc.exists ||
          userDoc.data()?['userType'] == null ||
          !(userDoc.data()?['registrationCompleted'] as bool? ?? false);

      return AuthResult(
        success: true,
        needsRegistration: needsRegistration,
        user: userCredential.user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        needsRegistration: false,
        error: e.toString(),
      );
    }
  }

  /// Register with email and password
  Future<AuthResult> registerWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create initial user document in Firestore
      // This ensures we have a record even if onboarding is not completed
      // MUST include 'email' and 'userType' to satisfy security rules
      if (userCredential.user != null) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'email': email,
              'userType': 'genz', // Default to creator, required by security rules
              'registrationCompleted': false,
              'createdAt': FieldValue.serverTimestamp(),
              'authProvider': 'email',
            }, SetOptions(merge: true));
      }

      // Always needs registration for new accounts
      return AuthResult(
        success: true,
        needsRegistration: true,
        user: userCredential.user,
      );
    } catch (e) {
      return AuthResult(
        success: false,
        needsRegistration: false,
        error: e.toString(),
      );
    }
  }

  /// Complete user registration (Creator)
  Future<bool> completeRegistration(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user data (one-time fetch)
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromJson({...doc.data()!, 'uid': doc.id});
    } catch (e) {
      return null;
    }
  }

  /// Get user data stream (real-time updates)
  Stream<UserModel?> getUserDataStream(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists) return null;
          return UserModel.fromJson({...doc.data()!, 'uid': doc.id});
        });
  }

  /// Logout
  Future<void> logout() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// Reset registration status (for development/testing)
  /// This allows users to go through the onboarding flow again
  Future<void> resetRegistrationStatus() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .update({
      'registrationCompleted': false,
    });
  }

  /// Clear all user data and reset to fresh state (for development/testing)
  Future<void> clearUserData() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }

    // Delete user document
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .delete();
  }

  /// Send OTP to phone number
  Future<PhoneAuthResult> sendOTP(String phoneNumber) async {
    try {
      // Usar Completer para manejar correctamente los callbacks async
      final completer = Completer<PhoneAuthResult>();
      String? errorMessage;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification en Android - usuario ya verificado
          try {
            await _auth.signInWithCredential(credential);
            if (!completer.isCompleted) {
              completer.complete(PhoneAuthResult(
                success: true, 
                verificationId: 'auto-verified',
              ));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete(PhoneAuthResult(
                success: false, 
                error: e.toString(),
              ));
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          errorMessage = e.message ?? 'Verification failed';
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult(
              success: false, 
              error: errorMessage,
            ));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult(
              success: true, 
              verificationId: verificationId,
            ));
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          // No completar aquí - es solo timeout del auto-retrieval
        },
        forceResendingToken: _resendToken,
      );

      // Esperar resultado con timeout de seguridad
      return await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => PhoneAuthResult(
          success: false,
          error: 'Request timed out. Please try again.',
        ),
      );
    } catch (e) {
      return PhoneAuthResult(success: false, error: e.toString());
    }
  }

  /// Verify OTP code
  /// If user is already logged in (email/google/apple), link phone to existing account
  /// Otherwise, sign in with phone (new user)
  Future<AuthResult> verifyOTP(String otp, {String? phoneNumber}) async {
    try {
      if (_verificationId == null) {
        throw Exception('No verification ID found. Please request OTP first.');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      User? user;
      String? phoneToSave = phoneNumber;
      
      // Check if user is already logged in (from email/google/apple signup)
      if (_auth.currentUser != null) {
        // Linking phone to existing user
        
        // Link phone credential to existing user
        try {
          final userCredential = await _auth.currentUser!.linkWithCredential(credential);
          user = userCredential.user;
          phoneToSave = user?.phoneNumber ?? phoneNumber;
          // Phone linked successfully
        } on FirebaseAuthException catch (e) {
          if (kDebugMode) {
            debugPrint('Phone link failed: ${e.code}');
          }
          
          // If phone is already linked to another account, 
          // or credential already in use, just continue with current user
          if (e.code == 'credential-already-in-use' || 
              e.code == 'provider-already-linked') {
            user = _auth.currentUser;
            phoneToSave = phoneNumber ?? user?.phoneNumber;
          } else {
            rethrow;
          }
        }
        
        // Update phone number in Firestore (even if linking failed/skipped)
        // This ensures the phone is saved in user profile regardless of Auth linking
        if (user != null && phoneToSave != null && phoneToSave.isNotEmpty) {
          // Saving phone to Firestore
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .set({
                'phoneNumber': phoneToSave,
                'phoneVerified': true,
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
      } else {
        // No user logged in, sign in with phone (creates new user)
        // Signing in with phone (new user)
        final userCredential = await _auth.signInWithCredential(credential);
        user = userCredential.user;
        
        // Create initial user document for phone-only users
        if (user != null) {
          final userDoc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.uid)
              .get();
              
          if (!userDoc.exists) {
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(user.uid)
                .set({
                  'uid': user.uid,
                  'phoneNumber': user.phoneNumber,
                  'phoneVerified': true,
                  'userType': 'genz',
                  'registrationCompleted': false,
                  'createdAt': FieldValue.serverTimestamp(),
                  'authProvider': 'phone',
                }, SetOptions(merge: true));
          }
        }
      }

      // Check if user exists in Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user!.uid)
          .get();

      final needsRegistration = !userDoc.exists ||
          userDoc.data()?['userType'] == null ||
          !(userDoc.data()?['registrationCompleted'] as bool? ?? false);

      // OTP verified
      
      return AuthResult(
        success: true,
        needsRegistration: needsRegistration,
        user: user,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('OTP verification failed: $e');
      }
      return AuthResult(
        success: false,
        needsRegistration: false,
        error: e.toString(),
      );
    }
  }

  /// Resend OTP
  Future<PhoneAuthResult> resendOTP(String phoneNumber) async {
    return await sendOTP(phoneNumber);
  }
}

/// Auth result class
class AuthResult {
  final bool success;
  final bool needsRegistration;
  final User? user;
  final String? error;

  AuthResult({
    required this.success,
    required this.needsRegistration,
    this.user,
    this.error,
  });
}

/// Phone auth result class
class PhoneAuthResult {
  final bool success;
  final String? verificationId;
  final String? error;

  PhoneAuthResult({
    required this.success,
    this.verificationId,
    this.error,
  });
}

