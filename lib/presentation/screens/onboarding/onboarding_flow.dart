import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'phone_number_screen.dart';
import 'otp_verification_screen.dart';
import 'linkedin_screen.dart';
import 'full_name_screen.dart';
import 'how_identify_screen.dart';
import 'how_old_screen.dart';
import 'location_screen.dart';
import 'education_level_screen.dart';
import 'field_of_study_screen.dart';
import 'university_screen.dart';
import 'fill_socials_screen.dart';
import 'hourly_rate_screen.dart';
import 'how_find_us_screen.dart';
import 'profile_picture_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../../core/router/app_router.dart';

/// Provider para el estado del onboarding
final onboardingStateProvider = StateNotifierProvider<OnboardingStateNotifier, OnboardingState>((ref) {
  return OnboardingStateNotifier();
});

/// Estado del onboarding
class OnboardingState {
  final int currentStep;
  final Map<String, dynamic> userData;
  final bool isLoading;

  OnboardingState({
    this.currentStep = 0,
    this.userData = const {},
    this.isLoading = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    Map<String, dynamic>? userData,
    bool? isLoading,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      userData: userData ?? this.userData,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier para manejar el estado del onboarding
class OnboardingStateNotifier extends StateNotifier<OnboardingState> {
  OnboardingStateNotifier() : super(OnboardingState());

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateUserData(String key, dynamic value) {
    final newData = Map<String, dynamic>.from(state.userData);
    newData[key] = value;
    state = state.copyWith(userData: newData);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Resetear completamente el estado del onboarding
  void reset() {
    state = OnboardingState();
  }

  Future<bool> completeOnboarding(BuildContext context, WidgetRef ref) async {
    if (state.isLoading) return false; // Prevent double taps
    
    setLoading(true);
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      final firestore = FirebaseFirestore.instance;
      final userData = state.userData;
      
      // Upload profile image if exists
      String? profileImageUrl;
      final profileImagePath = userData['profileImage'] as String?;
      if (profileImagePath != null && profileImagePath.isNotEmpty) {
        final file = File(profileImagePath);
        if (await file.exists()) {
          final storage = FirebaseStorage.instance;
          final storageRef = storage.ref().child('profile_images/${user.uid}.jpg');
          await storageRef.putFile(file);
          profileImageUrl = await storageRef.getDownloadURL();
        }
      }

      // Parse full name
      final fullName = userData['fullName'] as String? ?? '';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      // Build user document matching Vue.js structure
      final userDoc = {
        'uid': user.uid,
        'email': user.email ?? '',
        'firstName': userData['firstName'] ?? firstName,
        'lastName': userData['lastName'] ?? lastName,
        'phoneNumber': userData['phoneNumber'],
        'profileImage': profileImageUrl ?? userData['profilePictureUrl'],
        'userType': 'genz',
        'registrationCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': FieldValue.serverTimestamp(),
        
        // Personal info
        'gender': userData['gender'],
        'age': userData['age'],
        
        // Location
        'location': userData['location'],
        
        // Academic info
        'academic': {
          'level': userData['educationLevel'],
          'major': userData['major'],
          'university': userData['university'],
        },
        
        // Socials
        'socialMedia': userData['socials'],
        
        // Rate
        'hourlyRate': userData['hourlyRate'],
        
        // How found us
        'source': userData['findUsSource'],
        
        // LinkedIn data if available
        if (userData['linkedIn'] != null) 'linkedIn': userData['linkedIn'],
      };

      // Save to Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userDoc, SetOptions(merge: true));

      // Set flag to bypass router redirect check (like Vue's window.location.href)
      ref.read(registrationJustCompletedProvider.notifier).state = true;
      
      // Invalidate the currentUserProvider to force a refresh for future checks
      ref.invalidate(currentUserProvider);

      // Set loading to false BEFORE navigating
      setLoading(false);
      
      if (context.mounted) {
        // Reset state for next time
        state = OnboardingState();
        
        // Clear the onboarding flow flag BEFORE navigating (while ref is still valid)
        ref.read(isInOnboardingFlowProvider.notifier).state = false;
        
        // Navigate to home - the registrationJustCompleted flag will bypass redirect
        context.go('/creator/home');
        
        return true;
      }
      return false;
    } catch (e) {
      setLoading(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing registration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }
}

/// Pantalla principal del flujo de onboarding
class OnboardingFlowScreen extends ConsumerStatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  ConsumerState<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends ConsumerState<OnboardingFlowScreen> {
  @override
  void initState() {
    super.initState();
    // Mark that we're in onboarding flow - prevents router redirects during phone auth
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isInOnboardingFlowProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    // Note: We can't use ref.read here as it may already be disposed
    // The flag will be cleared when the user navigates away naturally
    // or when they log out (which resets the flag in login/signup screens)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);

    // Lista de pantallas del onboarding - 14 pasos total
    // Flujo como Registration.vue:
    // 1. LinkedIn (opcional, puede skip)
    // 2. Phone + OTP
    // 3. Personal Info (name, gender, age)
    // 4. Location
    // 5. Education
    // 6. Socials
    // 7. Rate
    // 8. How find us
    // 9. Photo
    final screens = [
      const LinkedInScreen(),         // 0 - LinkedIn import (puede skip)
      const PhoneNumberScreen(),      // 1 - Phone number
      const OtpVerificationScreen(),  // 2 - OTP verification
      const FullNameScreen(),         // 3 - Full name
      const HowIdentifyScreen(),      // 4 - Gender
      const HowOldScreen(),           // 5 - Age
      const LocationScreen(),         // 6 - Where are you based?
      const EducationLevelScreen(),   // 7 - Education level
      const FieldOfStudyScreen(),     // 8 - Field of study/Major
      const UniversityScreen(),       // 9 - University
      const FillSocialsScreen(),      // 10 - Socials
      const HourlyRateScreen(),       // 11 - Hourly rate
      const HowFindUsScreen(),        // 12 - How did you find us
      const ProfilePictureScreen(),   // 13 - Profile picture
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: state.currentStep.clamp(0, screens.length - 1),
          children: screens,
        ),
      ),
    );
  }
}
