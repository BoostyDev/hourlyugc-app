import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo component - EXACTO de Figma (Node: 33-596)
/// Tamaño: 60x60px con gradiente, borde y sombra
/// El icono interior es el SVG local de 37.5x37.5px centrado
class FigmaLogo extends StatelessWidget {
  final double scale;

  const FigmaLogo({
    super.key,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60 * scale,
      height: 60 * scale,
      decoration: BoxDecoration(
        // Base white background
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 1.412 * scale,
        ),
        borderRadius: BorderRadius.circular(15 * scale),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(5, 5, 20, 0.07),
            blurRadius: 20.6 * scale,
            offset: Offset(0, 11 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14 * scale),
        child: Stack(
          children: [
            // Gradient overlay (207 degrees)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.45, -0.89), // ~207 degrees
                    end: Alignment(-0.45, 0.89),
                    colors: [
                      Color.fromRGBO(255, 255, 255, 0.2),
                      Color.fromRGBO(237, 252, 242, 0.2),
                      Color.fromRGBO(115, 226, 163, 0.2),
                      Color.fromRGBO(75, 214, 135, 0.2),
                    ],
                    stops: [0.20249, 0.38821, 0.68622, 0.88514],
                  ),
                ),
              ),
            ),
            // Logo icon - SVG LOCAL (37.5x37.5px centered)
            Center(
              child: SizedBox(
                width: 37.5 * scale,
                height: 37.5 * scale,
                child: SvgPicture.asset(
                  'assets/images/hourly_ugc_logo.svg',
                  width: 37.5 * scale,
                  height: 37.5 * scale,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
