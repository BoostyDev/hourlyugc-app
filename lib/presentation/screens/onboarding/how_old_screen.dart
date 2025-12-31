import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: How old are you? (Node 33-1630)
class HowOldScreen extends ConsumerStatefulWidget {
  const HowOldScreen({super.key});

  @override
  ConsumerState<HowOldScreen> createState() => _HowOldScreenState();
}

class _HowOldScreenState extends ConsumerState<HowOldScreen> {
  int _selectedAge = 18;

  void _handleContinue() {
    // Save age
    ref.read(onboardingStateProvider.notifier).updateUserData('age', _selectedAge);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "How old are you?",
      subtitle: "Some brands have age preferences for campaigns",
      currentStep: 6,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 30),
          
          // Age picker (simplified version)
          Container(
            height: 213,
            width: 297,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Center(
              child: Container(
                height: 177,
                width: 257,
                child: Stack(
                  children: [
                    // Selection highlight
                    Positioned(
                      top: 71,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    
                    // Age picker
                    Center(
                      child: SizedBox(
                        height: 177,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 35,
                          diameterRatio: 2.0,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (index) {
                            setState(() {
                              _selectedAge = 18 + index;
                            });
                          },
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (context, index) {
                              final age = 18 + index;
                              final isSelected = age == _selectedAge;
                              
                              return Center(
                                child: Text(
                                  '$age',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected 
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFF94A3B8),
                                    letterSpacing: -0.18,
                                  ),
                                ),
                              );
                            },
                            childCount: 100, // Ages 18 to 117
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Selected age display
          Text(
            '$_selectedAge years old',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.18,
            ),
          ),
        ],
      ),
    );
  }
}

