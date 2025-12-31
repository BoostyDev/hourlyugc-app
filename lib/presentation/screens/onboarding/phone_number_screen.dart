import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'widgets/onboarding_layout.dart';
import 'widgets/country_selector_modal.dart';
import 'onboarding_flow.dart';
import '../../../core/utils/country_data.dart';
import '../../widgets/custom_snackbar.dart';
import '../../providers/auth_provider.dart';

/// Pantalla: What's your phone number? (Node 33-682)
class PhoneNumberScreen extends ConsumerStatefulWidget {
  const PhoneNumberScreen({super.key});

  @override
  ConsumerState<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends ConsumerState<PhoneNumberScreen> {
  final _phoneController = TextEditingController();
  Country _selectedCountry = countries.firstWhere((c) => c.code == 'IN');
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please enter your phone number',
        type: SnackbarType.warning,
      );
      return;
    }

    // Validate phone number length
    if (phone.length < 8) {
      CustomSnackbar.show(
        context,
        message: 'Please enter a valid phone number',
        type: SnackbarType.error,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fullPhoneNumber = '${_selectedCountry.dialCode}$phone';
      
      // Save phone number
      ref.read(onboardingStateProvider.notifier).updateUserData(
        'phoneNumber',
        fullPhoneNumber,
      );

      // Send OTP via Firebase
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.sendOTP(fullPhoneNumber);

      if (!mounted) return;

      if (result.success) {
        CustomSnackbar.show(
          context,
          message: 'Code sent successfully!',
          type: SnackbarType.success,
        );

        // Go to next step (OTP verification)
        ref.read(onboardingStateProvider.notifier).nextStep();
      } else {
        CustomSnackbar.show(
          context,
          message: result.error ?? 'Failed to send code',
          type: SnackbarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Error: ${e.toString()}',
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountrySelectorModal(
        selectedCountry: _selectedCountry,
        onCountrySelected: (country) {
          setState(() {
            _selectedCountry = country;
          });
        },
      ),
    );
  }

  Future<void> _handleBack() async {
    // Show sign out confirmation dialog (no hay más pasos atrás)
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sign Out',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF059669), // Verde del tema
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Sign Out',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(loginProvider.notifier).logout();
      if (mounted) {
        context.go('/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "What's your phone number?",
      subtitle: "We'll send you a code to verify it",
      currentStep: 2,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _isLoading ? null : _handleContinue,
      isContinueEnabled: _phoneController.text.isNotEmpty && !_isLoading,
      isSignOutButton: false, // Solo LinkedIn tiene signout button
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Phone input con country code
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                // Country code selector (clickable)
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showCountrySelector,
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 8),
                      child: Row(
                        children: [
                          // Flag
                          Container(
                            width: 24,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _selectedCountry.flag,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCountry.dialCode,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.18,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xFF94A3B8),
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Divider
                Container(
                  width: 1,
                  height: 19,
                  color: const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 10),
                
                // Phone number input
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: -0.18,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      setState(() {}); // Update button state
                    },
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

