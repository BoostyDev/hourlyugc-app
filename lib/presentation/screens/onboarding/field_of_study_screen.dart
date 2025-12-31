import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';

/// Pantalla: Field of Study / Major
/// Como en Registration.vue step 6
class FieldOfStudyScreen extends ConsumerStatefulWidget {
  const FieldOfStudyScreen({super.key});

  @override
  ConsumerState<FieldOfStudyScreen> createState() => _FieldOfStudyScreenState();
}

class _FieldOfStudyScreenState extends ConsumerState<FieldOfStudyScreen> {
  String? _selectedMajor;

  // Major options from Registration.vue
  final List<String> _majorOptions = [
    'Business Administration',
    'Marketing',
    'Computer Science',
    'Information Technology',
    'Communications',
    'Graphic Design',
    'Digital Marketing',
    'Social Media Management',
    'Film & Video Production',
    'Photography',
    'Art & Design',
    'Psychology',
    'Sociology',
    'English',
    'Journalism',
    'Public Relations',
    'Advertising',
    'Economics',
    'Finance',
    'Accounting',
    'Engineering',
    'Data Science',
    'Web Development',
    'UX/UI Design',
    'Fashion Design',
    'Music',
    'Theatre Arts',
    'Other',
  ];

  void _handleContinue() {
    if (_selectedMajor == null) {
      CustomSnackbar.show(
        context,
        message: 'Please select your field of study',
        type: SnackbarType.warning,
      );
      return;
    }

    // Save major
    ref.read(onboardingStateProvider.notifier).updateUserData('major', _selectedMajor);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "What are you studying?",
      subtitle: "Select your major or field of study",
      currentStep: 9,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _selectedMajor != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Major options in a grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _majorOptions.map((major) {
              final isSelected = _selectedMajor == major;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMajor = major;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF059669).withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF059669) 
                          : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        major,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? const Color(0xFF059669)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Color(0xFF059669),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

