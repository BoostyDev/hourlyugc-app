import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: Enter your password (Node 33-1783)
class EnterPasswordScreen extends ConsumerStatefulWidget {
  const EnterPasswordScreen({super.key});

  @override
  ConsumerState<EnterPasswordScreen> createState() => _EnterPasswordScreenState();
}

class _EnterPasswordScreenState extends ConsumerState<EnterPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both passwords')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 6 characters')),
      );
      return;
    }

    // Save password
    ref.read(onboardingStateProvider.notifier).updateUserData('password', password);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  void _handleSkip() {
    // Skip password and go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  bool get _isValid {
    return _passwordController.text.isNotEmpty && 
           _confirmPasswordController.text.isNotEmpty &&
           _passwordController.text == _confirmPasswordController.text &&
           _passwordController.text.length >= 6;
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "Enter your password",
      subtitle: "Set a new password",
      currentStep: 3,
      totalSteps: 10,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _isValid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Password field
          Text(
            'Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
              letterSpacing: -0.16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.16,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '••••••••••',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF0F172A),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Confirm Password field
          Text(
            'Confirm Password',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
              letterSpacing: -0.16,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.16,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '••••••••••',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: const Color(0xFF0F172A),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Skip link
          Center(
            child: GestureDetector(
              onTap: _handleSkip,
              child: Text(
                'Skip',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF059669),
                  letterSpacing: -0.18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

