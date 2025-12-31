import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';

/// Pantalla: Add a profile picture (Node 33-818)
class ProfilePictureScreen extends ConsumerStatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  ConsumerState<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends ConsumerState<ProfilePictureScreen> {
  File? _profileImage;
  bool _isUploading = false;

  /// Mostrar opciones de cámara o galería
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Choose Photo',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 24),
            // Camera option
            _buildOptionTile(
              icon: Icons.camera_alt_rounded,
              iconColor: const Color(0xFF059669),
              title: 'Take Photo',
              subtitle: 'Use your camera',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(height: 1, indent: 72),
            // Gallery option
            _buildOptionTile(
              icon: Icons.photo_library_rounded,
              iconColor: const Color(0xFF3B82F6),
              title: 'Choose from Gallery',
              subtitle: 'Pick from your photos',
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
            // Cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (pickedFile != null && mounted) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: source == ImageSource.camera 
            ? 'Could not access camera'
            : 'Could not access gallery',
        type: SnackbarType.error,
      );
    }
  }

  Future<void> _handleContinue() async {
    if (_isUploading) return;
    
    setState(() => _isUploading = true);

    try {
      // Save profile image path
      if (_profileImage != null) {
        ref.read(onboardingStateProvider.notifier).updateUserData(
          'profileImage', 
          _profileImage!.path,
        );
      }

      // Complete onboarding
      if (mounted) {
        final success = await ref.read(onboardingStateProvider.notifier).completeOnboarding(context, ref);
        
        if (!success && mounted) {
          CustomSnackbar.show(
            context,
            message: 'Failed to complete registration. Please try again.',
            type: SnackbarType.error,
          );
          setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        message: 'Error: $e',
        type: SnackbarType.error,
      );
      setState(() => _isUploading = false);
    }
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingStateProvider);
    final isLoading = state.isLoading || _isUploading;

    return OnboardingLayout(
      title: "Add a profile picture",
      subtitle: "Profiles with photos get hired more often",
      currentStep: 14,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: isLoading ? null : _handleContinue,
      isContinueEnabled: true,
      isLoading: isLoading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Profile picture selector
          GestureDetector(
            onTap: isLoading ? null : _showImageSourceDialog,
            child: Stack(
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _profileImage != null 
                          ? const Color(0xFF059669) 
                          : const Color(0xFFE2E8F0),
                      width: _profileImage != null ? 3 : 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromRGBO(5, 5, 20, 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  size: 32,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to add',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                // Edit/Add button
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF059669).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _profileImage != null ? Icons.edit : Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Helper text
          Text(
            _profileImage != null 
                ? 'Looking great! Tap to change'
                : 'Add a photo to stand out',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Skip option
          if (_profileImage == null)
            TextButton(
              onPressed: isLoading ? null : _handleContinue,
              child: Text(
                'Skip for now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
