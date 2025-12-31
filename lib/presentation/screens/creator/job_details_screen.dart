import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import '../../providers/job_provider.dart';
import '../../providers/application_provider.dart';
import '../../providers/employer_provider.dart';
import '../../../data/models/job_model.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/centered_alert.dart';

/// Job details screen - Optimized & matches Figma
class JobDetailsScreen extends ConsumerStatefulWidget {
  final String jobId;

  const JobDetailsScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  bool _isApplying = false;
  bool _isSaved = false;
  bool _showFullDescription = false;

  Future<void> _handleApply() async {
    final job = ref.read(jobProvider(widget.jobId)).value;
    if (job == null) return;

    setState(() => _isApplying = true);

    try {
      final success = await ref.read(applyToJobProvider.notifier).apply(
        jobId: widget.jobId,
        employerId: job.employerId,
        jobTitle: job.title,
        companyName: job.companyName,
      );

      if (success && mounted) {
        context.pop();
        // Show centered alert instead of snackbar
        CenteredAlert.show(
          context,
          title: 'Application Submitted!',
          message: 'Your application has been sent successfully. The employer will review it soon.',
          confirmText: 'OK',
          isImportant: true,
        );
      }
    } catch (e) {
      if (mounted) {
        CenteredAlert.show(
          context,
          title: 'Error',
          message: 'Failed to submit application: $e',
          confirmText: 'OK',
          isImportant: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use stream provider for real-time updates (like Vue onSnapshot)
    final jobAsync = ref.watch(jobStreamProvider(widget.jobId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: jobAsync.when(
        data: (job) => job == null 
            ? const Center(child: Text('Job not found'))
            : _buildContent(job),
        loading: () => _buildLoadingSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  /// Skeleton loading for job details - smooth like Vue
  Widget _buildLoadingSkeleton() {
    return SafeArea(
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFE2E8F0),
        highlightColor: const Color(0xFFF8FAFC),
        child: Column(
          children: [
            // Cover image skeleton
            Container(
              height: 280,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            // Content skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 200,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: List.generate(3, (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: i > 0 ? 8 : 0),
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(JobModel job) {
    return Stack(
      children: [
        // Background with gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF10B981).withOpacity(0.2),
                const Color(0xFFA7F3D0).withOpacity(0.0),
              ],
              stops: const [0.0, 0.3],
            ),
            color: const Color(0xFFF8FAFC),
          ),
        ),

        // Main scrollable content
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover image + floating card stack
              Stack(
                children: [
                  // Cover image at top (background)
                  _buildCoverImage(job),

                  // Blur overlay behind the card
                  Positioned(
                    top: 200,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          height: 100,
                          color: const Color(0xFFF1F1F1).withOpacity(0.0),
                        ),
                      ),
                    ),
                  ),

                  // Floating content card (overlapping the image)
                  Container(
                    margin: const EdgeInsets.only(top: 126, left: 20, right: 20),
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F7FA).withOpacity(0.90),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(job),
                            const SizedBox(height: 18),
                            _buildAboutSection(job),
                            if (job.requirements != null && job.requirements!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _buildRequirementsSection(job),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // About the Company section
              const SizedBox(height: 24),
              _buildAboutCompanySection(job),

              // More Jobs section
              const SizedBox(height: 24),
              _buildMoreJobsSection(job),

              // Bottom padding for apply button
              const SizedBox(height: 140),
            ],
          ),
        ),

        // Top navigation
        _buildTopNav(),

        // Bottom apply button
        _buildApplyButton(),
      ],
    );
  }

  Widget _buildCoverImage(JobModel job) {
    // Priority: coverImage > companyLogo > placeholder
    final coverImage = job.coverImage;
    final companyLogo = job.companyLogo;

    // If we have a cover image, use it full screen
    if (coverImage != null && coverImage.isNotEmpty) {
      return SizedBox(
        height: 342,
        width: double.infinity,
        child: CachedNetworkImage(
          imageUrl: coverImage,
          fit: BoxFit.cover,
          placeholder: (_, __) => _buildPlaceholder(companyLogo),
          errorWidget: (_, __, ___) => _buildPlaceholder(companyLogo),
        ),
      );
    }

    // If no cover image but we have a company logo, show it centered with gradient background
    if (companyLogo != null && companyLogo.isNotEmpty) {
      return Container(
        height: 342,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF10B981), Color(0xFF38EF7D), Color(0xFFA7F3D0)],
          ),
        ),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF050514).withOpacity(0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: CachedNetworkImage(
                imageUrl: companyLogo,
                fit: BoxFit.cover,
                placeholder: (_, __) => const Center(
                  child: Icon(Icons.business, size: 48, color: Color(0xFF64748B)),
                ),
                errorWidget: (_, __, ___) => const Center(
                  child: Icon(Icons.business, size: 48, color: Color(0xFF64748B)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // No images at all - show gradient placeholder
    return _buildPlaceholder(null);
  }

  Widget _buildPlaceholder(String? fallbackLogo) {
    return Container(
      height: 342,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10B981), Color(0xFF38EF7D), Color(0xFFA7F3D0)],
        ),
      ),
      child: fallbackLogo != null && fallbackLogo.isNotEmpty
          ? Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CachedNetworkImage(
                    imageUrl: fallbackLogo,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _buildHourlyUGCLogo(),
                  ),
                ),
              ),
            )
          : _buildHourlyUGCLogo(),
    );
  }

  /// HourlyUGC logo placeholder - beautiful branding
  Widget _buildHourlyUGCLogo() {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF050514).withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SvgPicture.asset(
            'assets/images/logo_hourlyugc.svg',
            width: 80,
            height: 80,
          ),
        ),
      ),
    );
  }

  Widget _buildTopNav() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button (white)
            _buildCircleButton(
              icon: Icons.arrow_back,
              onTap: () => context.pop(),
            ),
            // Share & Save buttons
            Row(
              children: [
                // Share button (dark)
                _buildCircleButton(
                  icon: Icons.share,
                  isDark: true,
                  onTap: () {},
                ),
                const SizedBox(width: 12),
                // Favorite button (white)
                _buildCircleButton(
                  icon: _isSaved ? Icons.favorite : Icons.favorite_outline,
                  iconColor: _isSaved ? const Color(0xFFEF4444) : null,
                  onTap: () => setState(() => _isSaved = !_isSaved),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isDark = false,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF050514).withOpacity(0.1),
              blurRadius: 35,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: iconColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildHeader(JobModel job) {
    // Get real location (city) from employer, fallback to location field
    final displayLocation = job.location.isNotEmpty && job.location.toLowerCase() != 'remote'
        ? job.location
        : 'United States'; // Fallback

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Company logo + name + Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Company section
              Expanded(
                child: Row(
                  children: [
                    // Company Logo with shadow
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9.375),
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9837D3).withOpacity(0.18),
                            blurRadius: 24.44,
                            offset: const Offset(0, 1.875),
                          ),
                          BoxShadow(
                            color: const Color(0xFF402451).withOpacity(0.15),
                            blurRadius: 5,
                            offset: const Offset(0, 3.125),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9.375),
                        child: job.companyLogo != null && job.companyLogo!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: job.companyLogo!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _buildCompanyInitial(job.companyName),
                                errorWidget: (_, __, ___) => _buildCompanyInitial(job.companyName),
                              )
                            : _buildCompanyInitial(job.companyName),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Company Name
                    Expanded(
                      child: Text(
                        job.companyName.isNotEmpty ? job.companyName : 'Company',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Price pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '\$${job.budget.toStringAsFixed(0)}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _getPaymentSuffix(job.paymentType),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF475569),
                        letterSpacing: -0.16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Job title
          Text(
            job.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
              height: 1.17,
              letterSpacing: -0.15,
            ),
          ),

          const SizedBox(height: 2),

          // Meta info row with dots
          Row(
            children: [
              Text(
                '${job.applicantsCount} Applied',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF475569),
                  letterSpacing: -0.16,
                ),
              ),
              _buildDotSeparator(),
              Text(
                Formatters.timeAgo(job.createdAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: const Color(0xFF64748B),
                  letterSpacing: -0.16,
                ),
              ),
              _buildDotSeparator(),
              Flexible(
                child: Text(
                  displayLocation,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    letterSpacing: -0.16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Category tag
          _buildGradientPill(_getJobTypeLabel(job.jobType)),
        ],
      ),
    );
  }

  Widget _buildCompanyInitial(String companyName) {
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C';
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildDotSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Container(
        width: 3,
        height: 3,
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildGradientPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [Color(0xFFF5D0FE), Color(0xFFDB2777)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }



  Widget _buildAboutSection(JobModel job) {
    final description = job.description;
    final isLong = description.length > 250;
    final displayText = _showFullDescription || !isLong 
        ? description 
        : '${description.substring(0, 250)}...';

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About the Job',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.18,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: displayText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.43,
                    letterSpacing: -0.16,
                  ),
                ),
                if (isLong && !_showFullDescription)
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => setState(() => _showFullDescription = true),
                      child: Text(
                        ' show more',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF099250),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsSection(JobModel job) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Content Requirements',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.18,
            ),
          ),
          const SizedBox(height: 6),
          ...job.requirements!.take(5).map((req) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle, size: 18, color: Color(0xFF16B364)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    req,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                      letterSpacing: -0.16,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }


  Widget _buildApplyButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 115,
        child: Stack(
          children: [
            // Blur background
            Positioned.fill(
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    color: const Color(0xFFF1F1F1).withOpacity(0.0),
                  ),
                ),
              ),
            ),
            // Button
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: GestureDetector(
                onTap: _isApplying ? null : _handleApply,
                child: Container(
                  height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF9FF7C0),
                        Color(0xFF45D27B),
                        Color(0xFF129C8D),
                      ],
                      stops: [0.1, 0.37, 0.88],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF050514).withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Inner shadows for 3D effect
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF071411).withOpacity(0.1),
                                blurRadius: 1.5,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Button text
                      Center(
                        child: _isApplying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Apply',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.18,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPaymentSuffix(String? type) {
    if (type == null) return '/h';
    switch (type.toLowerCase()) {
      case 'hourly': return '/h';
      case 'per-post': return '/post';
      case 'monthly': return '/mo';
      case 'fixed': return '';
      default: return '/h';
    }
  }

  String _getJobTypeLabel(String? type) {
    if (type == null) return 'Other opportunities';
    switch (type.toLowerCase()) {
      case 'sales & lead generation':
      case 'sales':
      case 'lead-generation':
        return 'Sales & Lead Generation';
      case 'digital marketing':
      case 'marketing':
        return 'Digital Marketing';
      case 'ugc content creator':
      case 'ugc':
      case 'content-creator':
      case 'content creator':
        return 'UGC Content Creator';
      case 'brand ambassador':
      case 'ambassador':
        return 'Brand Ambassador';
      case 'customer service':
        return 'Customer Service';
      case 'social media manager':
      case 'social-media-manager':
        return 'Social Media Manager';
      default:
        return 'Other opportunities';
    }
  }


  /// About the Company section - Like Figma design with real employer data
  Widget _buildAboutCompanySection(JobModel job) {
    final employerAsync = ref.watch(employerProvider(job.employerId));

    return employerAsync.when(
      data: (employer) {
        final companyName = employer?.companyName ?? job.companyName;
        final industry = employer?.industry ?? 'E-commerce';
        final companySize = employer?.companySize ?? '1-10';
        final location = employer?.location ?? (job.location.isNotEmpty ? job.location : 'United States');
        final founded = employer?.founded; // Only show if exists
        final website = employer?.website;
        final companyLogo = employer?.companyLogo ?? job.companyLogo;
        final description = employer?.companyDescription ?? 'Creating quality content for brands and businesses.';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FA),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'About the Company',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Company logo + name + visit button row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Company logo (larger)
                    Container(
                      width: 49,
                      height: 49,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.white, width: 1.6),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF9837D3).withOpacity(0.18),
                            blurRadius: 40,
                            offset: const Offset(0, 3),
                          ),
                          BoxShadow(
                            color: const Color(0xFF402451).withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: companyLogo != null && companyLogo.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: companyLogo,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => _buildCompanyInitial(companyName),
                                errorWidget: (_, __, ___) => _buildCompanyInitial(companyName),
                              )
                            : _buildCompanyInitial(companyName),
                      ),
                    ),
                    const SizedBox(width: 7),

                    // Company name and industry
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            companyName.isNotEmpty ? companyName : 'Company',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            industry,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Visit button (only if website exists)
                    if (website != null && website.isNotEmpty)
                      GestureDetector(
                        onTap: () => _launchWebsite(website),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Visit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.arrow_outward,
                                size: 18,
                                color: Color(0xFF0F172A),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Company info cards (Founded if exists, Team Size, Location)
              Row(
                children: [
                  if (founded != null && founded.isNotEmpty) ...[
                    _buildCompanyInfoCard('Founded', founded),
                    const SizedBox(width: 3),
                  ],
                  _buildCompanyInfoCard('Team Size', companySize),
                  const SizedBox(width: 3),
                  _buildCompanyInfoCard('Location', location),
                ],
              ),
              const SizedBox(height: 8),

              // Company description
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    height: 1.43,
                    letterSpacing: -0.16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCompanyInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.16,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF475569),
                letterSpacing: -0.16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Launch website in external browser
  Future<void> _launchWebsite(String url) async {
    // Ensure URL has protocol
    String finalUrl = url;
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'https://$finalUrl';
    }

    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open website')),
        );
      }
    }
  }

  /// More Jobs section - Grid of related jobs
  Widget _buildMoreJobsSection(JobModel currentJob) {
    final recentJobsAsync = ref.watch(recentJobsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'More Jobs',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Jobs grid
        recentJobsAsync.when(
          data: (jobs) {
            // Filter out current job and take max 6
            final otherJobs = jobs.where((j) => j.id != currentJob.id).take(6).toList();
            if (otherJobs.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: otherJobs.map((job) => _buildMoreJobCard(job)).toList(),
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildMoreJobCard(JobModel job) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 48) / 2; // 2 cards per row with spacing

    return GestureDetector(
      onTap: () => context.push('/creator/jobs/${job.id}'),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job image
            Container(
              height: 109,
              width: double.infinity,
              margin: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  // Image or placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: job.coverImage != null && job.coverImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: job.coverImage!,
                            width: double.infinity,
                            height: 109,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _buildJobCardPlaceholder(),
                            errorWidget: (_, __, ___) => _buildJobCardPlaceholder(),
                          )
                        : _buildJobCardPlaceholder(),
                  ),

                  // Applicants badge
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Color(0xFF475569)),
                          const SizedBox(width: 2),
                          Text(
                            '${job.applicantsCount}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Job info
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title and company
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                            letterSpacing: -0.16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          job.companyName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: -0.12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Text(
                    '\$${job.budget.toStringAsFixed(0)}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCardPlaceholder() {
    return Container(
      width: double.infinity,
      height: 109,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10B981), Color(0xFF38EF7D)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/logo_hourlyugc.svg',
          width: 40,
          height: 40,
        ),
      ),
    );
  }
}
