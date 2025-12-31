import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: How did you find us? (Node 33-1449)
class HowFindUsScreen extends ConsumerStatefulWidget {
  const HowFindUsScreen({super.key});

  @override
  ConsumerState<HowFindUsScreen> createState() => _HowFindUsScreenState();
}

class _HowFindUsScreenState extends ConsumerState<HowFindUsScreen> {
  String? _selectedSource;

  void _handleContinue() {
    if (_selectedSource == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    // Save source
    ref.read(onboardingStateProvider.notifier).updateUserData('findUsSource', _selectedSource);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  void _handleSkip() {
    // Skip and go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  Widget _buildSourceIcon(String label) {
    IconData iconData;
    Color iconColor;
    
    switch (label) {
      case 'Instagram':
        iconData = Icons.camera_alt_outlined;
        iconColor = const Color(0xFFE4405F);
        break;
      case 'TikTok':
        iconData = Icons.music_note_outlined;
        iconColor = const Color(0xFF000000);
        break;
      case 'YouTube':
        iconData = Icons.play_circle_outline;
        iconColor = const Color(0xFFFF0000);
        break;
      case 'Google / Search':
        iconData = Icons.search_outlined;
        iconColor = const Color(0xFF4285F4);
        break;
      case 'Friends / Family':
        iconData = Icons.people_outline;
        iconColor = const Color(0xFF10B981);
        break;
      case 'Other':
      default:
        iconData = Icons.public_outlined;
        iconColor = const Color(0xFF64748B);
    }
    
    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }

  Widget _buildSourceOption(String label) {
    final isSelected = _selectedSource == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSource = label;
        });
      },
      child: Container(
        height: 52,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF16B364) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            // Icon
            SizedBox(
              width: 28,
              height: 28,
              child: Center(child: _buildSourceIcon(label)),
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
      title: "How did you find us?",
      subtitle: "Helps us improve HourlyUGC for creators like you",
      currentStep: 13,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _selectedSource != null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Source options
          _buildSourceOption('Instagram'),
          _buildSourceOption('TikTok'),
          _buildSourceOption('YouTube'),
          _buildSourceOption('Google / Search'),
          _buildSourceOption('Friends / Family'),
          _buildSourceOption('Other'),
          
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
