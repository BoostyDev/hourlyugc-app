import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// Splash Screen - EXACTO de Figma (Node: 33-678)
/// Gradiente verde con logo SVG blanco centrado
/// Gradient: linear-gradient(169deg, #9FF7C0 0.33%, #45D27B 20.48%, #129C8D 99.42%)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Mostrar splash por 2 segundos
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Wait for auth state to be ready
    final authState = ref.read(authStateProvider);
    
    // If still loading, wait a bit more
    if (authState.isLoading) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }
    
    // Verificar estado de autenticación
    final isAuthenticated = ref.read(authStateProvider).value != null;
    
    if (!isAuthenticated) {
      print('🔓 Not authenticated, going to onboarding');
      context.go('/onboarding');
      return;
    }
    
    // User is authenticated, check registration status
    final user = ref.read(currentUserProvider).value;
    
    // If user data not loaded yet, wait a bit and try again
    if (user == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }
    
    final currentUser = ref.read(currentUserProvider).value;
    final isRegistered = currentUser?.registrationCompleted ?? false;

    // Authenticated check complete
    
    if (isRegistered) {
      context.go('/creator/home');
    } else {
      context.go('/registration');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            // 169 grados = aproximadamente (-0.19, -0.98) a (0.19, 0.98)
            begin: Alignment(-0.19, -0.98),
            end: Alignment(0.19, 0.98),
            colors: [
              Color(0xFF9FF7C0), // #9FF7C0 - 0.33%
              Color(0xFF45D27B), // #45D27B - 20.48%
              Color(0xFF129C8D), // #129C8D - 99.42%
            ],
            stops: [0.0033, 0.2048, 0.9942],
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/Vector.svg',
            width: size.width * 0.7, // 70% del ancho de pantalla
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
