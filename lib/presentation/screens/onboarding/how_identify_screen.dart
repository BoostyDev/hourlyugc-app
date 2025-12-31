import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: How do you identify? (Node 33-885)
/// Usando assets SVG de Figma
class HowIdentifyScreen extends ConsumerStatefulWidget {
  const HowIdentifyScreen({super.key});

  @override
  ConsumerState<HowIdentifyScreen> createState() => _HowIdentifyScreenState();
}

class _HowIdentifyScreenState extends ConsumerState<HowIdentifyScreen> {
  String? _selectedGender;

  void _handleContinue() {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    // Save gender
    ref.read(onboardingStateProvider.notifier).updateUserData('gender', _selectedGender);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  Widget _buildGenderIcon(String label) {
    IconData iconData;
    Color iconColor = const Color(0xFF64748B);
    
    switch (label) {
      case 'Male':
        iconData = Icons.male_rounded;
        iconColor = const Color(0xFF3B82F6);
        break;
      case 'Female':
        iconData = Icons.female_rounded;
        iconColor = const Color(0xFFEC4899);
        break;
      case 'Other':
        iconData = Icons.transgender_rounded;
        iconColor = const Color(0xFF8B5CF6);
        break;
      case 'Prefer not to say':
      default:
        iconData = Icons.person_outline_rounded;
        iconColor = const Color(0xFF64748B);
    }
    
    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }

  Widget _buildGenderOption(String label) {
    final isSelected = _selectedGender == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            // Icon with fallback
            SizedBox(
              width: 28,
              height: 28,
              child: _buildGenderIcon(label),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "How do you identify?",
      subtitle: "Only used for better brand matching",
      currentStep: 5,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _selectedGender != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Gender options
          _buildGenderOption('Male'),
          _buildGenderOption('Female'),
          _buildGenderOption('Other'),
          _buildGenderOption('Prefer not to say'),
        ],
      ),
    );
  }
}
