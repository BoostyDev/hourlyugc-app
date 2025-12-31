import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'dart:ui';

/// WhatsApp-style camera preview screen with editing capabilities
class CameraPreviewScreen extends StatefulWidget {
  final File imageFile;
  final Function(File file, String? caption) onSend;

  const CameraPreviewScreen({
    super.key,
    required this.imageFile,
    required this.onSend,
  });

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();
  bool _isSending = false;
  late File _currentImageFile;
  
  // Image transformations
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  int _rotation = 0; // 0, 90, 180, 270

  @override
  void initState() {
    super.initState();
    _currentImageFile = widget.imageFile;
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_isSending) return;
    
    setState(() => _isSending = true);
    
    final caption = _captionController.text.trim().isNotEmpty 
        ? _captionController.text.trim() 
        : null;
    
    widget.onSend(_currentImageFile, caption);
    Navigator.of(context).pop();
  }

  Future<void> _cropImage() async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _currentImageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Image',
            toolbarColor: const Color(0xFF10B981),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
            activeControlsWidgetColor: const Color(0xFF10B981),
            cropFrameColor: const Color(0xFF10B981),
            cropGridColor: Colors.white54,
          ),
          IOSUiSettings(
            title: 'Edit Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.ratio4x3,
            ],
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _currentImageFile = File(croppedFile.path);
          // Reset transformations after crop
          _scale = 1.0;
          _offset = Offset.zero;
          _rotation = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error cropping image',
              style: GoogleFonts.plusJakartaSans(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _rotateImage() {
    setState(() {
      _rotation = (_rotation + 90) % 360;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Image preview with gestures for zooming/panning
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (details) {
                  _previousScale = _scale;
                  _previousOffset = _offset;
                },
                onScaleUpdate: (details) {
                  setState(() {
                    _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
                    if (_scale > 1.0) {
                      _offset = _previousOffset + details.focalPointDelta;
                    } else {
                      _offset = Offset.zero;
                    }
                  });
                },
                onDoubleTap: () {
                  setState(() {
                    if (_scale > 1.0) {
                      _scale = 1.0;
                      _offset = Offset.zero;
                    } else {
                      _scale = 2.0;
                    }
                  });
                },
                child: Transform.translate(
                  offset: _offset,
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform.rotate(
                      angle: _rotation * 3.14159 / 180,
                      child: Image.file(
                        _currentImageFile,
                        fit: BoxFit.contain,
                        key: ValueKey(_currentImageFile.path),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Top bar with close and edit buttons
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopBar(),
            ),
            
            // Bottom bar with caption input and send button
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          // Actions row
          Row(
            children: [
              // Crop button
              GestureDetector(
                onTap: _cropImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.crop,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Rotate button
              GestureDetector(
                onTap: _rotateImage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Caption input
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _captionController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: const Color(0xFF0F172A),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a caption...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    cursorColor: const Color(0xFF10B981),
                    cursorWidth: 2,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Send button
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF11998E),
                        Color(0xFF38EF7D),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: _isSending
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Hint text
          Text(
            'Tap crop to edit • Pinch to zoom • Double tap to zoom in/out',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
