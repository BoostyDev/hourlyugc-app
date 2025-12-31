import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';

/// Pantalla: Education Level
/// Como en Registration.vue step 5
class EducationLevelScreen extends ConsumerStatefulWidget {
  const EducationLevelScreen({super.key});

  @override
  ConsumerState<EducationLevelScreen> createState() => _EducationLevelScreenState();
}

class _EducationLevelScreenState extends ConsumerState<EducationLevelScreen> {
  String? _selectedLevel;

  // Academic levels from Registration.vue
  final List<String> _academicLevels = [
    'High School Student',
    'High School Graduate',
    'College Freshman',
    'College Sophomore',
    'College Junior',
    'College Senior',
    'Graduate Student',
    'Recent Graduate',
    'Other',
  ];

  void _handleContinue() {
    if (_selectedLevel == null) {
      CustomSnackbar.show(
        context,
        message: 'Please select your education level',
        type: SnackbarType.warning,
      );
      return;
    }

    // Save education level
    ref.read(onboardingStateProvider.notifier).updateUserData('educationLevel', _selectedLevel);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  Widget _buildLevelOption(String level) {
    final isSelected = _selectedLevel == level;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                level,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFF059669),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
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
      title: "What's your education level?",
      subtitle: "This helps brands understand your background",
      currentStep: 8,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _selectedLevel != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Education level options
          ..._academicLevels.map((level) => _buildLevelOption(level)),
        ],
      ),
    );
  }
}

