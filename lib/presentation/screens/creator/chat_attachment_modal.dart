import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Clean, minimal attachment modal - app design style
class AttachmentModal extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onVideo;
  final VoidCallback onAudio;
  final VoidCallback? onFile;

  const AttachmentModal({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onVideo,
    required this.onAudio,
    this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactOption(
            icon: Icons.photo_library_outlined,
            label: 'Gallery',
            onTap: () {
              Navigator.pop(context);
              onGallery();
            },
          ),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          _buildCompactOption(
            icon: Icons.folder_outlined,
            label: 'Files',
            onTap: () {
              Navigator.pop(context);
              if (onFile != null) {
                onFile!();
              } else {
                onGallery();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCompactOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF64748B),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid-style attachment modal (alternative design)
class AttachmentModalGrid extends StatelessWidget {
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onVideo;
  final VoidCallback onAudio;
  final VoidCallback? onFile;

  const AttachmentModalGrid({
    super.key,
    required this.onCamera,
    required this.onGallery,
    required this.onVideo,
    required this.onAudio,
    this.onFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Options
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AttachmentOption(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    color: const Color(0xFF10B981),
                    onTap: onCamera,
                  ),
                  _AttachmentOption(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    color: const Color(0xFF3B82F6),
                    onTap: onGallery,
                  ),
                  _AttachmentOption(
                    icon: Icons.videocam,
                    label: 'Video',
                    color: const Color(0xFFEF4444),
                    onTap: onVideo,
                  ),
                  _AttachmentOption(
                    icon: Icons.audiotrack,
                    label: 'Audio',
                    color: const Color(0xFF8B5CF6),
                    onTap: onAudio,
                  ),
                ],
              ),
            ),
            if (onFile != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _AttachmentOption(
                      icon: Icons.insert_drive_file,
                      label: 'File',
                      color: const Color(0xFFF59E0B),
                      onTap: onFile!,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF0F172A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
