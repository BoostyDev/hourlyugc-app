import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';

/// Debug screen for development/testing
/// Allows resetting registration status and clearing user data
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Debug Tools',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Development Tools',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Use these tools to reset your session and test the onboarding flow',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // Reset Registration Button
              _buildActionCard(
                context: context,
                title: 'Reset Registration',
                description: 'Mark registration as incomplete. You\'ll go through onboarding again.',
                icon: Icons.refresh,
                color: Colors.orange,
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    'Reset Registration?',
                    'This will mark your registration as incomplete. You\'ll be redirected to the onboarding flow.',
                  );
                  
                  if (confirm == true) {
                    try {
                      await ref.read(loginProvider.notifier).resetRegistration();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Registration reset! Redirecting...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Wait a bit then navigate
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          context.go('/registration');
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),

              const SizedBox(height: 16),

              // Clear User Data Button
              _buildActionCard(
                context: context,
                title: 'Clear User Data',
                description: 'Delete all user data from Firestore. You\'ll start fresh.',
                icon: Icons.delete_forever,
                color: Colors.red,
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    'Clear All Data?',
                    'This will DELETE all your user data from Firestore. This action cannot be undone!',
                  );
                  
                  if (confirm == true) {
                    try {
                      await ref.read(loginProvider.notifier).clearUserData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('User data cleared! Redirecting...'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Wait a bit then navigate
                        await Future.delayed(const Duration(seconds: 1));
                        if (context.mounted) {
                          context.go('/registration');
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),

              const SizedBox(height: 16),

              // Logout Button
              _buildActionCard(
                context: context,
                title: 'Logout',
                description: 'Sign out of your account',
                icon: Icons.logout,
                color: Colors.blue,
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context,
                    'Logout?',
                    'Are you sure you want to sign out?',
                  );
                  
                  if (confirm == true) {
                    try {
                      await ref.read(loginProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/onboarding');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
              ),

              const Spacer(),

              // Warning
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.amber),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'These tools are for development only. Use with caution!',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
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

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
            ),
            child: Text(
              'Confirm',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

