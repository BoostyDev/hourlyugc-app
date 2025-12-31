import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Layout común para todas las pantallas de onboarding
class OnboardingLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final bool isLoading;
  final bool isContinueEnabled;
  final int currentStep;
  final int totalSteps;
  final bool isSignOutButton; // Si es true, muestra icono de logout rojo

  const OnboardingLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.onBack,
    this.onContinue,
    this.isLoading = false,
    this.isContinueEnabled = true,
    this.currentStep = 1,
    this.totalSteps = 9, // 9 pasos totales (eliminamos Enter Password)
    this.isSignOutButton = false, // Por defecto es false (botón de back normal)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header con back button y progress bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Back button (o Sign Out button si isSignOutButton es true)
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(5, 5, 20, 0.1),
                        blurRadius: 35,
                      ),
                    ],
                  ),
                  child: Icon(
                    isSignOutButton ? Icons.logout : Icons.arrow_back,
                    size: 24,
                    color: const Color(0xFF0F172A), // Mismo color para ambos
                  ),
                ),
              ),
              const SizedBox(width: 15),
              // Progress bar
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: (currentStep / totalSteps).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(-0.195, -0.981),
                          end: Alignment(0.195, 0.981),
                          colors: [
                            Color(0xFF9FF7C0),
                            Color(0xFF45D27B),
                            Color(0xFF129C8D),
                          ],
                          stops: [0.1058, 0.3713, 0.8803],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.2,
                height: 38 / 32,
              ),
            ),
          ),
        ),

        // Subtitle (optional)
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF64748B),
                  height: 24 / 16,
                ),
              ),
            ),
          ),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: child,
          ),
        ),

        // Continue button
        Padding(
          padding: const EdgeInsets.all(20),
          child: _buildContinueButton(context),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final isEnabled = isContinueEnabled && !isLoading;
    
    return GestureDetector(
      onTap: isEnabled ? onContinue : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.7,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 4,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(5, 5, 20, 0.1),
                blurRadius: 15,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999 - 4),
            child: Stack(
              children: [
                // Main gradient background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.195, -0.981),
                      end: Alignment(0.195, 0.981),
                      colors: [
                        Color(0xFF9FF7C0),
                        Color(0xFF45D27B),
                        Color(0xFF129C8D),
                      ],
                      stops: [0.1058, 0.3713, 0.8803],
                    ),
                  ),
                ),
                
                // Inner shadow overlay for glossy effect
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.transparent,
                          Colors.transparent,
                          const Color.fromRGBO(7, 20, 17, 0.1),
                        ],
                        stops: const [0.0, 0.15, 0.85, 1.0],
                      ),
                    ),
                  ),
                ),

                // Ellipse decoration (top-right shine)
                Positioned(
                  right: -20,
                  top: -15,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Container(
                      width: 85,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: RadialGradient(
                          center: Alignment.center,
                          radius: 1.0,
                          colors: [
                            Colors.white.withOpacity(0.6),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Button content
                Center(
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Continue',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.18,
                                color: Colors.white,
                                height: 22 / 16,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward,
                              size: 18,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

