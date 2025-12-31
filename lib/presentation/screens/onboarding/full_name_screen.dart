import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: What should we call you? (Node 33-851)
class FullNameScreen extends ConsumerStatefulWidget {
  const FullNameScreen({super.key});

  @override
  ConsumerState<FullNameScreen> createState() => _FullNameScreenState();
}

class _FullNameScreenState extends ConsumerState<FullNameScreen> {
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full name')),
      );
      return;
    }

    // Save full name
    ref.read(onboardingStateProvider.notifier).updateUserData('fullName', fullName);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "What should we call you?",
      subtitle: "This will be shown to brands",
      currentStep: 4,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _fullNameController.text.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Full name input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _fullNameController.text.isNotEmpty 
                    ? const Color(0xFF059669) 
                    : const Color(0xFFE2E8F0),
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                // Cursor indicator (green line)
                if (_fullNameController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      width: 1,
                      height: 24,
                      color: const Color(0xFF059669),
                    ),
                  ),
                
                // Text input
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: _fullNameController.text.isNotEmpty ? 10 : 20,
                      right: 20,
                    ),
                    child: TextField(
                      controller: _fullNameController,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter your full name',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: -0.18,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

