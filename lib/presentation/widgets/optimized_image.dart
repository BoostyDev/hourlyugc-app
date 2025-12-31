import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized network image with caching and shimmer loading
/// This prevents re-downloading images and provides smooth loading UX
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// Helper to safely convert dimension to int (handles infinity/NaN)
  int? _safeToInt(double? value) {
    if (value == null) return null;
    if (value.isInfinite || value.isNaN) return null;
    return value.toInt();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      // Use custom placeholder if provided, otherwise default
      Widget result = placeholder ?? _buildPlaceholder();
      // Ensure placeholder has correct size
      if (width != null || height != null) {
        result = SizedBox(
          width: width,
          height: height,
          child: result,
        );
      }
      if (borderRadius != null) {
        result = ClipRRect(
          borderRadius: borderRadius!,
          child: result,
        );
      }
      return result;
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Use memory cache and disk cache (safely handle infinity)
      memCacheWidth: _safeToInt(width),
      memCacheHeight: _safeToInt(height),
      // Shimmer loading placeholder
      placeholder: (context, url) => placeholder ?? _buildShimmerPlaceholder(),
      // Error widget
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      // Fade in animation for smooth appearance
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildPlaceholder() {
    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.3),
            const Color(0xFF059669).withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: Colors.white54),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildErrorWidget() {
    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
      ),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, size: 32, color: Color(0xFF94A3B8)),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    return content;
  }
}

/// Optimized avatar image with circular shape
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Widget? placeholder;

  const OptimizedAvatar({
    super.key,
    required this.imageUrl,
    this.size = 48,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return placeholder ?? _buildDefaultAvatar();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      memCacheWidth: (size * 2).toInt(), // 2x for retina
      memCacheHeight: (size * 2).toInt(),
      imageBuilder: (context, imageProvider) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => _buildShimmerAvatar(),
      errorWidget: (context, url, error) => placeholder ?? _buildDefaultAvatar(),
      fadeInDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.8),
            const Color(0xFF059669),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, color: Colors.white, size: size * 0.6),
    );
  }
}

/// Optimized job image for cards with specific styling
class OptimizedJobImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;

  const OptimizedJobImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(16),
      placeholder: _buildJobPlaceholder(),
      errorWidget: _buildJobPlaceholder(),
    );
  }

  Widget _buildJobPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.3),
            const Color(0xFF059669).withOpacity(0.3),
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.work_outline, size: 48, color: Colors.white54),
      ),
    );
  }
}

