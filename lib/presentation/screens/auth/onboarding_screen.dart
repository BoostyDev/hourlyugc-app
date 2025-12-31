import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../../../core/utils/figma_assets_updated.dart';
import '../../widgets/figma_logo.dart';
import '../../widgets/figma_tagline.dart';
import '../onboarding/onboarding_flow.dart';
import '../../../core/router/app_router.dart';

/// Enum para indicar el lado del blur en las imágenes
enum BlurSide {
  none,   // Sin blur (imagen central)
  left,   // Blur en lado izquierdo de la imagen
  right,  // Blur en lado derecho de la imagen
}

/// Onboarding screen - IMPLEMENTACIÓN EXACTA DE FIGMA
/// Con botón glossy, logo SVG local, fuentes y blur gradual
/// Todos los SVGs se cargan localmente para mejor rendimiento
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final scale = width / 402;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0, -1),
            end: Alignment(0, 1),
            colors: [
              Color.fromRGBO(16, 185, 129, 0.2),
              Color.fromRGBO(167, 243, 208, 0),
            ],
            stops: [0.0, 0.29863],
          ),
          color: Color(0xFFF8FAFC),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20 * scale),
                    child: FigmaTagline(scale: scale),
                  ),
                  SizedBox(
                    height: 439 * scale,
                    child: _buildBanner(width, scale),
                  ),
                  SizedBox(height: 20 * scale),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale),
                    child: _buildContent(context, ref, width, scale),
                  ),
                  SizedBox(height: 34 * scale),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(double width, double scale) {
    return SizedBox(
      width: width,
      height: 439 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Left card CON blur integrado DENTRO del borde
          Positioned(
            left: -93.73 * scale,
            top: 48.37 * scale,
            child: Transform.rotate(
              angle: 0.122173, // 7 degrees
              child: _buildImageCardWithBlur(
                FigmaAssetsUpdated.imgFrame97,
                scale,
                blurSide: BlurSide.left,
              ),
            ),
          ),

          // Right card CON blur integrado DENTRO del borde
          Positioned(
            right: -93.73 * scale,
            top: 70 * scale,
            child: Transform.rotate(
              angle: 0.05236, // 3 degrees
              child: _buildImageCardWithBlur(
                FigmaAssetsUpdated.imgFrame98,
                scale,
                blurSide: BlurSide.right,
              ),
            ),
          ),

          // Center card - SIN blur, imagen normal
          Positioned(
            left: width / 2 - (245 * scale / 2),
            top: 40.85 * scale,
            child: Transform.rotate(
              angle: -0.036, // -2 degrees
              child: _buildImageCardWithBlur(
                FigmaAssetsUpdated.imgFrame96,
                scale,
                blurSide: BlurSide.none,
              ),
            ),
          ),

          // Fire icon - SVG LOCAL 🔥 (sin rotación)
          Positioned(
            left: 37.75 * scale,
            bottom: 34 * scale,
            child: SvgPicture.asset(
              FigmaAssetsUpdated.fireSvg,
              width: 50 * scale,
              height: 62 * scale,
              fit: BoxFit.contain,
            ),
          ),

          // +$30 Price badge
          Positioned(
            right: 60 * scale,
            top: 130.3 * scale,
            child: Transform.rotate(
              angle: 0.087, // 5 degrees
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 5 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDFCF2),
                  border: Border.all(color: Colors.white, width: 0.8 * scale),
                  borderRadius: BorderRadius.circular(10 * scale),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromRGBO(5, 5, 20, 0.1),
                      blurRadius: 13.7 * scale,
                      offset: Offset(0, 5 * scale),
                    ),
                  ],
                ),
                child: Text(
                  '+\$30',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF059669),
                    height: 24 / 20,
                  ),
                ),
              ),
            ),
          ),

          // Heart icon - SVG LOCAL ❤️
          Positioned(
            right: 65 * scale,
            top: 13.64 * scale,
            child: Transform.rotate(
              angle: 0.175, // 10 degrees
              child: SvgPicture.asset(
                FigmaAssetsUpdated.heartSvg,
                width: 52.71 * scale,
                height: 52.71 * scale,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }


  /// Imagen con blur integrado DENTRO del borde blanco
  Widget _buildImageCardWithBlur(String imageUrl, double scale, {required BlurSide blurSide}) {
    return Container(
      width: 245 * scale,
      height: 302 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32 * scale),
        border: Border.all(color: Colors.white, width: 4 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(5, 5, 20, 0.2),
            blurRadius: 36 * scale,
            offset: Offset(0, 11 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28 * scale),
        child: Stack(
          children: [
            // Imagen base
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.image, size: 80 * scale, color: Colors.grey),
                ),
              ),
            ),
            
            // Gradiente lineal blanco DENTRO del borde (solo para imágenes laterales)
            if (blurSide != BlurSide.none)
              Positioned(
                left: blurSide == BlurSide.left ? 0 : null,
                right: blurSide == BlurSide.right ? 0 : null,
                top: 0,
                bottom: 0,
                width: 200 * scale, // Ancho mayor para que el gradiente cubra más área
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // Para imagen IZQUIERDA: gradiente va del borde al centro
                      // Para imagen DERECHA: gradiente va del centro al borde
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: blurSide == BlurSide.left 
                          ? const [
                              Color(0xFFF8FAFC), // 100% - Blanco opaco (borde izquierdo)
                              Color(0xE6F8FAFC), // 90%
                              Color(0xB3F8FAFC), // 70%
                              Color(0x66F8FAFC), // 40%
                              Color(0x00F8FAFC), // 0% - Transparente (centro)
                            ]
                          : const [
                              Color(0x00F8FAFC), // 0% - Transparente (centro)
                              Color(0x66F8FAFC), // 40%
                              Color(0xB3F8FAFC), // 70%
                              Color(0xE6F8FAFC), // 90%
                              Color(0xFFF8FAFC), // 100% - Blanco opaco (borde derecho)
                            ],
                      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, double width, double scale) {
    return Column(
      children: [
        // Logo with local SVG
        FigmaLogo(scale: scale),
        SizedBox(height: 12 * scale),
        // Heading with Switzer-like font (Plus Jakarta Sans)
        Text(
          'Create Content,',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36 * scale,
            fontWeight: FontWeight.w500,
            height: 42 / 36,
            letterSpacing: -0.3,
            color: const Color(0xFF0F172A),
          ),
        ),
        Text(
          'Get Paid Hourly',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36 * scale,
            fontWeight: FontWeight.w500,
            height: 42 / 36,
            letterSpacing: -0.3,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 20 * scale),
        _buildGetStartedButton(context, ref, width, scale),
        SizedBox(height: 22 * scale),
        _buildFooter(context, scale),
      ],
    );
  }

  /// BUTTON with glossy effect - EXACTO de Figma (Node 33-600)
  Widget _buildGetStartedButton(BuildContext context, WidgetRef ref, double width, double scale) {
    return GestureDetector(
      onTap: () {
        // Resetear estado del onboarding antes de ir a signup
        ref.read(onboardingStateProvider.notifier).reset();
        ref.read(isInOnboardingFlowProvider.notifier).state = false;
        context.go('/signup');
      },
      child: Container(
        width: width - (40 * scale),
        height: 58 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 4 * scale,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(5, 5, 20, 0.1),
              blurRadius: 15 * scale,
              offset: Offset(0, 7 * scale),
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
                right: -20 * scale,
                top: -15 * scale,
                child: Transform.rotate(
                  angle: -0.4,
                  child: Container(
                    width: 85 * scale,
                    height: 32 * scale,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get Started',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.18,
                        color: Colors.white,
                        height: 22 / 16,
                      ),
                    ),
                    SizedBox(width: 2 * scale),
                    Icon(
                      Icons.arrow_forward,
                      size: 18 * scale,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, double scale) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.go('/login'),
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.18,
                color: const Color(0xFF475569),
                height: 22 / 16,
              ),
              children: [
                const TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Sign in',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.18,
                    color: const Color(0xFF059669),
                    height: 22 / 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 8 * scale),
        SizedBox(
          width: 310 * scale,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.dmSans(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 16 / 12,
              ),
              children: [
                const TextSpan(text: 'By continuing, you agree to our '),
                TextSpan(
                  text: 'Terms & Conditions',
                  style: GoogleFonts.dmSans(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF059669),
                    height: 16 / 12,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy.',
                  style: GoogleFonts.dmSans(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF059669),
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
