import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/onboarding_screen.dart';
import '../../presentation/screens/onboarding/onboarding_flow.dart';
import '../../presentation/screens/creator/creator_home_screen.dart';
import '../../presentation/screens/creator/jobs_screen.dart';
import '../../presentation/screens/creator/applications_screen.dart';
import '../../presentation/screens/creator/chat_screen.dart';
import '../../presentation/screens/creator/payout_screen.dart';
import '../../presentation/screens/creator/job_details_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/debug/debug_screen.dart';

/// Flag to bypass redirect after registration completion
/// This is set by completeOnboarding and cleared after navigation
final registrationJustCompletedProvider = StateProvider<bool>((ref) => false);

/// Flag to indicate we're in the middle of onboarding flow
/// Prevents router from redirecting during phone auth
final isInOnboardingFlowProvider = StateProvider<bool>((ref) => false);

/// Notifier for router refresh - only changes when we explicitly want to redirect
class RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final routerRefreshProvider = Provider<RouterRefreshNotifier>((ref) {
  return RouterRefreshNotifier();
});

/// Router provider - uses ref.read instead of ref.watch to avoid unnecessary rebuilds
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      // Get current values using read (not watch) to avoid rebuilds
      final container = ProviderScope.containerOf(context);
      final authState = container.read(authStateProvider);
      final currentUser = container.read(currentUserProvider);
      final justCompleted = container.read(registrationJustCompletedProvider);
      final isInOnboarding = container.read(isInOnboardingFlowProvider);
      
      // Allow splash screen to handle its own navigation
      if (state.matchedLocation == '/') {
        return null;
      }

      // If we're in the middle of onboarding flow, DON'T redirect at all
      // This prevents any interference during the entire registration process
      if (isInOnboarding) {
        return null;
      }

      // If registration just completed, allow navigation to home without checking
      if (justCompleted && state.matchedLocation == '/creator/home') {
        return null;
      }

      final isAuthenticated = authState.value != null;
      final user = currentUser.value;
      final isRegistered = user?.registrationCompleted ?? false;

      final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/onboarding';
      final isRegistrationRoute = state.matchedLocation == '/registration';

      // If not authenticated, allow onboarding, login, signup and registration
      if (!isAuthenticated && !isAuthRoute && !isRegistrationRoute) {
        return '/onboarding';
      }

      // If authenticated but not registered, go to registration
      // ONLY if not already there AND not on auth routes (they're navigating there)
      if (isAuthenticated && !isRegistered && !isRegistrationRoute && !isAuthRoute) {
        return '/registration';
      }

      // If authenticated and registered, redirect from auth pages to home
      if (isAuthenticated && isRegistered && isAuthRoute) {
        return '/creator/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Multi-step onboarding flow (phone, OTP, password, etc.)
      GoRoute(
        path: '/registration',
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // Creator routes
      GoRoute(
        path: '/creator/home',
        builder: (context, state) => const CreatorHomeScreen(),
      ),
      GoRoute(
        path: '/creator/jobs',
        builder: (context, state) => const JobsScreen(),
      ),
      GoRoute(
        path: '/creator/jobs/:id',
        builder: (context, state) {
          final jobId = state.pathParameters['id']!;
          return JobDetailsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: '/creator/applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: '/creator/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/creator/payout',
        builder: (context, state) => const PayoutScreen(),
      ),

      // Debug tools (for development)
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugScreen(),
      ),
    ],
  );
});

