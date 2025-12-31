import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';

/// Pantalla: What's your hourly rate? (Node 33-750)
class HourlyRateScreen extends ConsumerStatefulWidget {
  const HourlyRateScreen({super.key});

  @override
  ConsumerState<HourlyRateScreen> createState() => _HourlyRateScreenState();
}

class _HourlyRateScreenState extends ConsumerState<HourlyRateScreen> {
  final _rateController = TextEditingController(text: '35');
  String _currency = 'USD';

  @override
  void dispose() {
    _rateController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    final rate = _rateController.text.trim();
    if (rate.isEmpty || double.tryParse(rate) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid hourly rate')),
      );
      return;
    }

    // Save hourly rate
    ref.read(onboardingStateProvider.notifier).updateUserData('hourlyRate', {
      'amount': double.parse(rate),
      'currency': _currency,
    });

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "What's your hourly rate?",
      subtitle: "You can change this anytime",
      currentStep: 12,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _rateController.text.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // Rate input
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Currency selector
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Text('🇺🇸', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 5),
                    Text(
                      _currency,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.18,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF475569)),
                  ],
                ),
              ),
              
              const SizedBox(width: 10),
              
              // Rate input
              Container(
                width: 115,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _rateController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.15,
                    height: 30 / 24,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                ),
              ),
              
              const SizedBox(width: 10),
              
              // /hour label
              Text(
                '/ hour',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

