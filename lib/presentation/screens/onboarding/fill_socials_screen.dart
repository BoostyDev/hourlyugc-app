import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: What are your socials? (Node 33-1367)
/// Solo Instagram y TikTok como en Vue Registration.vue
class FillSocialsScreen extends ConsumerStatefulWidget {
  const FillSocialsScreen({super.key});

  @override
  ConsumerState<FillSocialsScreen> createState() => _FillSocialsScreenState();
}

class _FillSocialsScreenState extends ConsumerState<FillSocialsScreen> {
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();

  @override
  void dispose() {
    _instagramController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  int get _filledCount {
    int count = 0;
    if (_instagramController.text.trim().isNotEmpty) count++;
    if (_tiktokController.text.trim().isNotEmpty) count++;
    return count;
  }

  bool get _isValid {
    // At least one social is required
    return _filledCount >= 1;
  }

  void _handleContinue() {
    // Save socials
    ref.read(onboardingStateProvider.notifier).updateUserData('socials', {
      'instagram': _instagramController.text.trim(),
      'tiktok': _tiktokController.text.trim(),
    });

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  Widget _buildSocialIcon(String platform) {
    IconData iconData;
    Color iconColor;
    
    switch (platform) {
      case 'instagram':
        iconData = Icons.camera_alt_outlined;
        iconColor = const Color(0xFFE4405F);
        break;
      case 'tiktok':
        iconData = Icons.music_note_outlined;
        iconColor = const Color(0xFF000000);
        break;
      default:
        iconData = Icons.link_outlined;
        iconColor = const Color(0xFF64748B);
    }
    
    return Icon(
      iconData,
      size: 24,
      color: iconColor,
    );
  }

  Widget _buildSocialField({
    required String platform,
    required String placeholder,
    required TextEditingController controller,
  }) {
    final hasValue = controller.text.isNotEmpty;
    
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasValue ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
          width: hasValue ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          // Platform Icon
          SizedBox(
            width: 28,
            height: 28,
            child: Center(child: _buildSocialIcon(platform)),
          ),
          const SizedBox(width: 10),
          // Text input
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.18,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: placeholder,
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: -0.18,
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Checkmark when filled
          if (hasValue) ...[
            const Icon(
              Icons.check_circle,
              color: Color(0xFF059669),
              size: 20,
            ),
            const SizedBox(width: 16),
          ] else
            const SizedBox(width: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "What are your socials?",
      subtitle: "Add your social accounts to help brands review your work before hiring",
      currentStep: 11,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _isValid,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Instagram
          _buildSocialField(
            platform: 'instagram',
            placeholder: 'Your Instagram username',
            controller: _instagramController,
          ),
          
          const SizedBox(height: 12),
          
          // TikTok
          _buildSocialField(
            platform: 'tiktok',
            placeholder: 'Your TikTok username',
            controller: _tiktokController,
          ),
          
          const SizedBox(height: 24),
          
          // Counter and info
          Center(
            child: Text(
              _filledCount >= 1 
                  ? '$_filledCount account${_filledCount > 1 ? 's' : ''} added ✓'
                  : 'Add at least 1 account',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _filledCount >= 1 
                    ? const Color(0xFF059669) 
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
