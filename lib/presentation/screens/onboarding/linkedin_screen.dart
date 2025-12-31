import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';
import '../../providers/auth_provider.dart';
import '../../../core/config/env_config.dart';
import '../../../core/router/app_router.dart';

/// Pantalla: Connect LinkedIn (Step 1 para creators)
/// Como en Registration.vue - importa datos de LinkedIn para autocompletar
class LinkedInScreen extends ConsumerStatefulWidget {
  const LinkedInScreen({super.key});

  @override
  ConsumerState<LinkedInScreen> createState() => _LinkedInScreenState();
}

class _LinkedInScreenState extends ConsumerState<LinkedInScreen> {
  final _linkedInController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;
  Map<String, dynamic>? _linkedInData;
  String? _errorMessage;

  @override
  void dispose() {
    _linkedInController.dispose();
    super.dispose();
  }

  /// Construye la URL de LinkedIn desde el username
  String _buildLinkedInUrl(String input) {
    if (input.startsWith('http')) {
      return input;
    }
    // Limpiar el username
    String username = input.trim();
    if (username.startsWith('@')) {
      username = username.substring(1);
    }
    // Remover espacios y caracteres especiales
    username = username.replaceAll(' ', '').toLowerCase();
    return 'https://www.linkedin.com/in/$username/';
  }

  /// Importar datos de LinkedIn usando el backend existente
  Future<void> _importLinkedIn() async {
    final input = _linkedInController.text.trim();
    if (input.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please enter your LinkedIn username or URL',
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 120);

      final linkedInUrl = _buildLinkedInUrl(input);
      
      // Llamar al backend existente
      final response = await dio.post(
        EnvConfig.linkedInApiUrl,
        data: {'linkedinUrl': linkedInUrl},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;
        
        if (data != null && (data['headline'] != null || (data['experiences'] as List?)?.isNotEmpty == true)) {
          setState(() {
            _linkedInData = data;
            _isSuccess = true;
            _isLoading = false;
          });

          // Guardar datos de LinkedIn en el estado del onboarding
          final notifier = ref.read(onboardingStateProvider.notifier);
          
          // Guardar todo el perfil de LinkedIn
          notifier.updateUserData('linkedIn', {
            'username': input,
            'profileUrl': linkedInUrl,
            'headline': data['headline'],
            'skills': data['skills'] ?? [],
            'experiences': data['experiences'] ?? [],
            'education': data['education'] ?? [],
            'photoUrl': data['photoUrl'],
            'summary': data['summary'],
          });

          // Auto-rellenar nombre si está disponible
          if (data['firstName'] != null) {
            notifier.updateUserData('firstName', data['firstName']);
          }
          if (data['lastName'] != null) {
            notifier.updateUserData('lastName', data['lastName']);
          }
          if (data['photoUrl'] != null) {
            notifier.updateUserData('profilePictureUrl', data['photoUrl']);
          }

          if (mounted) {
            CustomSnackbar.show(
              context,
              message: 'LinkedIn profile imported successfully!',
              type: SnackbarType.success,
            );
          }
        } else {
          throw Exception('No data found in LinkedIn profile');
        }
      } else {
        throw Exception(response.data['error'] ?? 'Failed to import LinkedIn data');
      }
    } on DioException catch (e) {
      String message = 'Failed to connect to LinkedIn service';
      if (e.type == DioExceptionType.connectionTimeout) {
        message = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        message = 'Request timeout. LinkedIn may be slow, please try again.';
      } else if (e.response?.statusCode == 400) {
        message = 'Invalid LinkedIn URL. Please check and try again.';
      } else if (e.response?.statusCode == 500) {
        message = 'LinkedIn service temporarily unavailable.';
      }
      
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _handleContinue() {
    if (_isSuccess) {
      // LinkedIn imported, go to next step
      ref.read(onboardingStateProvider.notifier).nextStep();
    } else {
      // Try to import first
      _importLinkedIn();
    }
  }

  void _handleSkip() {
    // Skip LinkedIn and go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  /// Mostrar modal de confirmación para logout
  void _showSignOutModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout,
                color: Color(0xFFEF4444),
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            
            // Title
            Text(
              'Sign Out?',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              'Are you sure you want to sign out? Your progress will not be saved.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Sign out button
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _performSignOut();
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Ejecutar logout y resetear estado
  Future<void> _performSignOut() async {
    try {
      // IMPORTANTE: Resetear el estado del onboarding ANTES de logout
      ref.read(onboardingStateProvider.notifier).reset();
      ref.read(isInOnboardingFlowProvider.notifier).state = false;
      
      await ref.read(loginProvider.notifier).logout();
      if (mounted) {
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) {
        CustomSnackbar.show(
          context,
          message: 'Error signing out: $e',
          type: SnackbarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "Connect your LinkedIn",
      subtitle: "Import your profile to save time filling out your info",
      currentStep: 1,
      totalSteps: 14, // Ahora son 14 pasos con LinkedIn
      onBack: _showSignOutModal, // Mostrar modal de confirmación
      onContinue: _isLoading ? null : _handleContinue,
      isContinueEnabled: !_isLoading,
      isLoading: _isLoading,
      isSignOutButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // LinkedIn input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _isSuccess 
                    ? const Color(0xFF059669) 
                    : _errorMessage != null 
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFE2E8F0),
                width: _isSuccess || _errorMessage != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                // LinkedIn icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A66C2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Text(
                      'in',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _linkedInController,
                    enabled: !_isLoading && !_isSuccess,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.18,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'username or linkedin.com/in/username',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: -0.18,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                  ),
                ),
                if (_isSuccess)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 24,
                    ),
                  )
                else if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0A66C2),
                      ),
                    ),
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Error message
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Success - show imported data preview
          if (_isSuccess && _linkedInData != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_linkedInData!['photoUrl'] != null)
                        ClipOval(
                          child: Image.network(
                            _linkedInData!['photoUrl'],
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2E8F0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Color(0xFF94A3B8)),
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_linkedInData!['firstName'] ?? ''} ${_linkedInData!['lastName'] ?? ''}'.trim(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            if (_linkedInData!['headline'] != null)
                              Text(
                                _linkedInData!['headline'],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF64748B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF059669),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Profile imported successfully',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          // Info text
          if (!_isSuccess) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A66C2).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Color(0xFF0A66C2),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save time with LinkedIn import',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'We\'ll auto-fill your name, photo, and experience',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Skip link
          Center(
            child: GestureDetector(
              onTap: _isLoading ? null : _handleSkip,
              child: Text(
                'Skip for now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isLoading 
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF059669),
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

