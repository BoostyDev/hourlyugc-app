import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';
import '../../providers/auth_provider.dart';

/// Pantalla: Enter the verification code (Node 33-714)
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Add listeners to focus nodes to rebuild on focus change
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != 6) {
      CustomSnackbar.show(
        context,
        message: 'Please enter the complete 6-digit code',
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the phone number from onboarding state
      final userData = ref.read(onboardingStateProvider).userData;
      final phoneNumber = userData['phoneNumber'] as String?;
      
      // Verify OTP with Firebase
      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.verifyOTP(otp, phoneNumber: phoneNumber);

      if (!mounted) return;

      if (result.success) {
        // Save OTP
        ref.read(onboardingStateProvider.notifier).updateUserData('otp', otp);

        CustomSnackbar.show(
          context,
          message: 'Phone verified successfully!',
          type: SnackbarType.success,
        );

        // Go to next step
        ref.read(onboardingStateProvider.notifier).nextStep();
      } else {
        CustomSnackbar.show(
          context,
          message: result.error ?? 'Invalid verification code',
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

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  Future<void> _handleResend() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    try {
      final state = ref.read(onboardingStateProvider);
      final phoneNumber = state.userData['phoneNumber'] as String?;

      if (phoneNumber == null) {
        CustomSnackbar.show(
          context,
          message: 'Phone number not found',
          type: SnackbarType.error,
        );
        return;
      }

      final authRepo = ref.read(authRepositoryProvider);
      final result = await authRepo.resendOTP(phoneNumber);

      if (!mounted) return;

      if (result.success) {
        CustomSnackbar.show(
          context,
          message: 'Code sent again!',
          type: SnackbarType.success,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: result.error ?? 'Failed to resend code',
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
        setState(() => _isResending = false);
      }
    }
  }

  bool get _isCodeComplete {
    return _controllers.every((controller) => controller.text.isNotEmpty);
  }

  Widget _buildOtpBox(int index) {
    final hasFocus = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;
    
    // Determinar color del borde
    Color borderColor;
    double borderWidth;
    
    if (hasFocus) {
      borderColor = const Color(0xFF059669);
      borderWidth = 2;
    } else if (hasValue) {
      borderColor = const Color(0xFF059669);
      borderWidth = 1.5;
    } else {
      borderColor = const Color(0xFFE2E8F0);
      borderWidth = 1;
    }
    
    return Expanded(
      child: Container(
        height: 56,
        margin: EdgeInsets.only(right: index < 5 ? 8 : 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
          boxShadow: hasFocus
              ? [
                  BoxShadow(
                    color: const Color(0xFF059669).withOpacity(0.15),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color.fromRGBO(5, 5, 20, 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
              height: 1,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            onChanged: (value) {
              setState(() {}); // Update UI
              if (value.isNotEmpty && index < 5) {
                // Move to next field
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                // Move to previous field on delete
                _focusNodes[index - 1].requestFocus();
              }
            },
            onTap: () {
              // Select all text when tapped
              _controllers[index].selection = TextSelection(
                baseOffset: 0,
                extentOffset: _controllers[index].text.length,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);
    final phoneNumber = state.userData['phoneNumber'] ?? '+34611338282';

    return OnboardingLayout(
      title: "Enter the verification code",
      subtitle: "We sent you a 6-digit code to $phoneNumber",
      currentStep: 3,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _isLoading ? null : _handleContinue,
      isContinueEnabled: _isCodeComplete && !_isLoading,
      isLoading: _isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // OTP input boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) => _buildOtpBox(index)),
          ),
          
          const SizedBox(height: 24),
          
          // Send Again link
          Center(
            child: GestureDetector(
              onTap: _isResending ? null : _handleResend,
              child: _isResending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF059669),
                        ),
                      ),
                    )
                  : Text(
                      'Send Again',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF059669),
                        letterSpacing: -0.18,
                        height: 22 / 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
