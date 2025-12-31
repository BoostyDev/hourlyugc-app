import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../onboarding/onboarding_flow.dart';
import '../../../core/router/app_router.dart';

/// Login screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    
    // Activar flag ANTES del auth para prevenir redirecciones
    ref.read(onboardingStateProvider.notifier).reset();
    ref.read(isInOnboardingFlowProvider.notifier).state = true;
    
    try {
      final result = await ref.read(loginProvider.notifier).loginWithGoogle();
      
      if (result.success && mounted) {
        if (result.needsRegistration) {
          context.go('/registration');
        } else {
          ref.read(isInOnboardingFlowProvider.notifier).state = false;
          context.go('/creator/home');
        }
      } else if (result.error != null && mounted) {
        ref.read(isInOnboardingFlowProvider.notifier).state = false;
        _showError(result.error!);
      }
    } catch (e) {
      ref.read(isInOnboardingFlowProvider.notifier).state = false;
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // TODO: Implementar Apple Login si es necesario
  // Future<void> _handleAppleLogin() async {
  //   setState(() => _isLoading = true);
  //   
  //   ref.read(onboardingStateProvider.notifier).reset();
  //   ref.read(isInOnboardingFlowProvider.notifier).state = true;
  //   
  //   try {
  //     final result = await ref.read(loginProvider.notifier).loginWithApple();
  //     
  //     if (result.success && mounted) {
  //       if (result.needsRegistration) {
  //         context.go('/registration');
  //       } else {
  //         ref.read(isInOnboardingFlowProvider.notifier).state = false;
  //         context.go('/creator/home');
  //       }
  //     } else if (result.error != null && mounted) {
  //       ref.read(isInOnboardingFlowProvider.notifier).state = false;
  //       _showError(result.error!);
  //     }
  //   } catch (e) {
  //     ref.read(isInOnboardingFlowProvider.notifier).state = false;
  //     if (mounted) _showError(e.toString());
  //   } finally {
  //     if (mounted) setState(() => _isLoading = false);
  //   }
  // }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    ref.read(onboardingStateProvider.notifier).reset();
    ref.read(isInOnboardingFlowProvider.notifier).state = true;
    
    try {
      final result = await ref.read(loginProvider.notifier).loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result.success && mounted) {
        if (result.needsRegistration) {
          context.go('/registration');
        } else {
          ref.read(isInOnboardingFlowProvider.notifier).state = false;
          context.go('/creator/home');
        }
      } else if (result.error != null && mounted) {
        ref.read(isInOnboardingFlowProvider.notifier).state = false;
        _showError(result.error!);
      }
    } catch (e) {
      ref.read(isInOnboardingFlowProvider.notifier).state = false;
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Back button
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 35,
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, size: 24),
                        onPressed: () => context.go('/onboarding'),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Title and subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start earning with UGC content.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Form
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email field
                      const Text(
                        'Email Address or Phone Number',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          letterSpacing: -0.16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'brian@email.com',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFF059669),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password field
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF475569),
                          letterSpacing: -0.16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: '••••••••••',
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: const Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF0F172A),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: const BorderSide(
                              color: Color(0xFF059669),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Sign in button - EXACTO como "Get Started"
                      GestureDetector(
                        onTap: _isLoading ? null : _handleEmailLogin,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.35),
                              width: 4,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(5, 5, 20, 0.1),
                                blurRadius: 15,
                                offset: Offset(0, 7),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999 - 4),
                            child: Stack(
                              children: [
                                // Main gradient background
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment(-0.195, -0.981),
                                      end: Alignment(0.195, 0.981),
                                      colors: [
                                        Color(0xFF9FF7C0),
                                        Color(0xFF45D27B),
                                        Color(0xFF129C8D),
                                      ],
                                      stops: [0.1058, 0.3713, 0.8803],
                                    ),
                                  ),
                                ),
                                
                                // Inner shadow overlay for glossy effect
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.5),
                                          Colors.transparent,
                                          Colors.transparent,
                                          const Color.fromRGBO(7, 20, 17, 0.1),
                                        ],
                                        stops: const [0.0, 0.15, 0.85, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // Ellipse decoration (top-right shine)
                                Positioned(
                                  right: -20,
                                  top: -15,
                                  child: Transform.rotate(
                                    angle: -0.4,
                                    child: Container(
                                      width: 85,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        gradient: RadialGradient(
                                          center: Alignment.center,
                                          radius: 1.0,
                                          colors: [
                                            Colors.white.withOpacity(0.6),
                                            Colors.white.withOpacity(0.0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Button content
                                Center(
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Sign in',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: -0.18,
                                                color: Colors.white,
                                                height: 22 / 16,
                                              ),
                                            ),
                                            const SizedBox(width: 2),
                                            const Icon(
                                              Icons.arrow_forward,
                                              size: 18,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFF64748B)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF64748B),
                                letterSpacing: -0.7,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Google button
                      Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleGoogleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F172A),
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.network(
                                'https://www.google.com/favicon.ico',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Continue with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: -0.18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Footer
                      Center(
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF475569),
                                  letterSpacing: -0.18,
                                ),
                                children: [
                                  const TextSpan(text: "Don't have an account? "),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () => context.go('/signup'),
                                      child: const Text(
                                        'Sign up',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF059669),
                                          letterSpacing: -0.18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'By continuing, you agree to our Terms & Conditions and Privacy Policy.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

