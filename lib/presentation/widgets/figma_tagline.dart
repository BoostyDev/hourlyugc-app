import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tagline badge component - EXACTO de Figma (Node: 33-663)
/// "Join 2,000+ creators earning hourly" con shine icon y gradient text
class FigmaTagline extends StatelessWidget {
  final double scale;

  const FigmaTagline({
    super.key,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 6 * scale,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(24 * scale),
        // Multi-stop gradient background
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFE2E8F0),
            Color(0xFFF1F5F9),
            Color(0xFFFFFFFF),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
          ],
          stops: [0.0, 0.10036, 0.5, 0.92123, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(5, 5, 20, 0.07),
            blurRadius: 12 * scale,
            offset: Offset(0, 3 * scale),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Shine icon (16x16px)
          _buildShineIcon(scale),
          SizedBox(width: 3 * scale),
          // Gradient text
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment(-0.984, -0.177), // ~258 degrees
              end: Alignment(0.984, 0.177),
              colors: [
                Color(0xFF129C8D),
                Color(0xFF45D27B),
                Color(0xFF73D799),
                Color(0xFF45D27B),
                Color(0xFF129C8D),
              ],
              stops: [0.00968, 0.44629, 0.49203, 0.53881, 0.97008],
            ).createShader(bounds),
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.16,
                  height: 20 / 14,
                  color: Colors.white,
                ),
                children: [
                  const TextSpan(text: 'Join '),
                  TextSpan(
                    text: '2,000+',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.16,
                      height: 20 / 14,
                    ),
                  ),
                  const TextSpan(text: ' creators earning hourly'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shine/sparkle icon - SVG local de Figma
  Widget _buildShineIcon(double scale) {
    return SizedBox(
      width: 20 * scale,
      height: 20 * scale,
      child: SvgPicture.asset(
        'assets/icons/shine.svg',
        width: 20 * scale,
        height: 20 * scale,
        fit: BoxFit.contain,
      ),
    );
  }
}
