import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EXACT text styles from Figma design system
/// Fonts: Switzer (headings/labels), DM Sans (body)
class FigmaTextStyles {
  // Heading styles
  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w500, // Medium
        height: 42 / 36, // lineHeight / fontSize
        letterSpacing: -0.3,
        color: const Color(0xFF0F172A), // text/primary
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w500, // Medium
        height: 38 / 32,
        letterSpacing: -0.2,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get h6 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w500, // Medium
        height: 24 / 20,
        letterSpacing: 0,
        color: const Color(0xFF0F172A),
      );

  // Label styles
  static TextStyle get label1Regular => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        height: 22 / 16,
        letterSpacing: -0.18,
        color: const Color(0xFF475569), // text/secondary
      );

  static TextStyle get label1Medium => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500, // Medium
        height: 22 / 16,
        letterSpacing: -0.18,
        color: const Color(0xFF0F172A),
      );

  static TextStyle get label1SemiBold => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600, // SemiBold
        height: 22 / 16,
        letterSpacing: -0.18,
        color: Colors.white,
      );

  static TextStyle get label2Regular => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400, // Regular
        height: 20 / 14,
        letterSpacing: -0.16,
        color: const Color(0xFF475569),
      );

  static TextStyle get label2Medium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500, // Medium
        height: 20 / 14,
        letterSpacing: -0.16,
        color: const Color(0xFF0F172A),
      );

  // Body styles (DM Sans)
  static TextStyle get body2Regular => GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400, // Regular
        height: 24 / 16,
        letterSpacing: 0,
        color: const Color(0xFF64748B), // text/tertiary
      );

  static TextStyle get body4Regular => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400, // Regular
        height: 16 / 12,
        letterSpacing: 0,
        color: const Color(0xFF64748B),
      );

  static TextStyle get body4Medium => GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w500, // Medium
        height: 16 / 12,
        letterSpacing: 0,
        color: const Color(0xFF059669), // emerald/600
      );

  // Color variations
  static TextStyle get emeraldText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 22 / 16,
        letterSpacing: -0.18,
        color: const Color(0xFF059669), // emerald/600
      );

  static TextStyle get whiteText => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 22 / 16,
        letterSpacing: -0.18,
        color: Colors.white,
      );
}

/// Figma color palette
class FigmaColors {
  // Text colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF64748B);

  // Brand colors
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981);

  // Background colors
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF8FAFC);

  // Border colors
  static const Color borderSecondary = Color(0xFFE2E8F0);
  static const Color borderPrimary = Color(0xFFCBD5E1);

  // Gradient colors for buttons
  static const List<Color> buttonGradient = [
    Color(0xFF9FF7C0), // Light green
    Color(0xFF45D27B), // Medium green
    Color(0xFF129C8D), // Dark teal
  ];

  // Gradient for tagline text
  static const List<Color> taglineGradient = [
    Color(0xFF129C8D),
    Color(0xFF45D27B),
    Color(0xFF73D799),
    Color(0xFF45D27B),
    Color(0xFF129C8D),
  ];
}

