import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';
import '../../providers/job_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../../data/models/job_model.dart';
import '../../../data/models/notification_model.dart';
import '../onboarding/onboarding_flow.dart';
import '../../../core/router/app_router.dart';
import '../../widgets/skeleton_loaders.dart';
import '../../widgets/optimized_image.dart';
import '../../widgets/centered_alert.dart';

/// Creator home/dashboard screen - Figma Design Node 33:2382
class CreatorHomeScreen extends ConsumerStatefulWidget {
  const CreatorHomeScreen({super.key});

  @override
  ConsumerState<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends ConsumerState<CreatorHomeScreen> {
  int _selectedNavIndex = 0;
  bool _showReferralBanner = true;
  final Set<String> _shownNotifications = {}; // Track shown notifications to avoid duplicates

  void _handleNotifications(List<NotificationModel> notifications) {
    for (var notification in notifications) {
      // Only show new notifications that haven't been shown
      if (!_shownNotifications.contains(notification.id) && !notification.isRead) {
        _shownNotifications.add(notification.id);
        
        // Show centered alert for important notifications
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              CenteredAlert.show(
                context,
                title: notification.title,
                message: notification.message,
                confirmText: 'View',
                cancelText: 'Dismiss',
                isImportant: true,
                onConfirm: () {
                  // Navigate based on notification type
                  if (notification.type == 'contract_proposal') {
                    final contractId = notification.data?['contractId'];
                    if (contractId != null) {
                      // TODO: Navigate to contract
                    }
                  } else if (notification.type == 'application_status') {
                    // TODO: Navigate to applications
                  }
                },
              );
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final recentJobsAsync = ref.watch(recentJobsProvider);
    
    // Listen to notifications - must be inside build method
    ref.listen<AsyncValue<List<NotificationModel>>>(
      notificationsProvider,
      (previous, next) {
        next.whenData((notifications) => _handleNotifications(notifications));
      },
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content with Pull-to-Refresh
            RefreshIndicator(
              onRefresh: () async {
                // Invalidate providers to refresh data
                ref.invalidate(recentJobsProvider);
                ref.invalidate(currentUserProvider);
                // Small delay for smooth animation
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: const Color(0xFF10B981),
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              displacement: 40,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  children: [
                    // Header Section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildHeader(context, currentUser),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Balance Card Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildBalanceSection(currentUser),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Referral Banner
                    if (_showReferralBanner)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildReferralBanner(),
                      ),
                    
                    if (_showReferralBanner) const SizedBox(height: 12),
                    
                    // Jobs Grid - Uses stream for real-time updates (smooth like Vue)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: recentJobsAsync.when(
                        data: (jobs) => _buildJobsGrid(jobs),
                        // Use skeleton loader instead of spinner for better UX
                        loading: () => const JobsGridSkeleton(itemCount: 4),
                        error: (e, st) => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text('Error loading jobs', style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => ref.invalidate(recentJobsProvider),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue currentUser) {
    return Row(
      children: [
        // Logo and greeting
        Expanded(
          child: Row(
            children: [
              // Logo - HourlyUGC
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF69FFB4).withOpacity(0.18),
                      blurRadius: 39,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: const Color(0xFF66A384).withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      const Color(0xFFEDFCF2).withOpacity(0.8),
                      const Color(0xFF73E2A3).withOpacity(0.3),
                    ],
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/logo_hourlyugc.svg',
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi! Good to see you',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  currentUser.when(
                    data: (user) => Text(
                      user?.firstName ?? 'Creator',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    loading: () => Container(
                      width: 80,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (_, __) => Text(
                      'Creator',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Actions
        Row(
          children: [
            // Notification bell with real count
            Consumer(
              builder: (context, ref, _) {
                final unreadCount = ref.watch(unreadNotificationsCountProvider);
                return GestureDetector(
                  onTap: () {
                    // TODO: Open notifications screen
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF050514).withOpacity(0.1),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: SvgPicture.asset(
                            'assets/icons/Bell.svg',
                            width: 24,
                            height: 24,
                            colorFilter: const ColorFilter.mode(
                              Color(0xFF0F172A),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        // Red notification dot (only if unread > 0)
                        if (unreadCount > 0)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            // Profile avatar - Optimized with cached image
            GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF050514).withOpacity(0.1),
                      blurRadius: 35,
                    ),
                  ],
                ),
                child: currentUser.when(
                  data: (user) => OptimizedAvatar(
                    imageUrl: user?.profileImage,
                    size: 48,
                    placeholder: _buildDefaultAvatar(),
                  ),
                  loading: () => const SkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: 24,
                  ),
                  error: (_, __) => _buildDefaultAvatar(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 48,
      height: 48,
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
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  Widget _buildBalanceSection(AsyncValue currentUser) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Balance Card with gradient - Figma Node 33:2434 (BG)
          Container(
            height: 193,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Figma Quepal gradient: #11998E -> #38EF7D
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF11998E), // Teal
                  Color(0xFF38EF7D), // Green
                ],
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                // Glow effects using containers with gradients (replacing removed PNG assets)
                Positioned(
                  left: -40,
                  top: -30,
                  child: Container(
                    width: 188,
                    height: 182,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -50,
                  bottom: -30,
                  child: Container(
                    width: 210,
                    height: 215,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF10B981).withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start, // Align to top
                        children: [
                          // Balance info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Figma: Label/Label-2/Medium - Switzer 14px
                              Text(
                                'Total Balance',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14, // Figma: 14px
                                  fontWeight: FontWeight.w500, // Figma: Medium
                                  color: Colors.white, // Figma: #FFF
                                  height: 20 / 14, // Figma: line-height 20px
                                  letterSpacing: -0.16, // Figma: -0.16px
                                ),
                              ),
                              // Figma: Heading/H2/Medium - Switzer 48px
                              currentUser.when(
                                data: (user) => Text(
                                  '\$${(user?.balance ?? 0.0).toStringAsFixed(2)}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 48, // Figma: 48px
                                    fontWeight: FontWeight.w500, // Figma: Medium
                                    color: Colors.white, // Figma: #FFF
                                    height: 58 / 48, // Figma: line-height 58px
                                    letterSpacing: -0.4, // Figma: -0.4px
                                  ),
                                ),
                                loading: () => Text(
                                  '\$0.00',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.5),
                                    height: 58 / 48,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                                error: (_, __) => Text(
                                  '\$0.00',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                    height: 58 / 48,
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Get Paid button - positioned higher, more elongated
                          Container(
                            margin: const EdgeInsets.only(top: 4), // Move up
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => context.push('/creator/payout'),
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                  // More elongated: increased horizontal padding
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Text(
                                    'Get Paid',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF0F172A),
                                      letterSpacing: -0.18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Activity indicator - Daily earnings trend (21 days)
                      // Shows tall line if earnings that day, small dot if no earnings
                      Row(
                        children: List.generate(21, (index) {
                          // Calculate if there were earnings on this day
                          // For now, use a simple pattern - in real app, fetch from completed jobs
                          final hasEarnings = _hasEarningsForDay(index, currentUser);
                          // Height: tall line (almost full height ~40px) if earnings, small dot (7px) if not
                          final height = hasEarnings ? 40.0 : 7.0;
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 6,
                            height: height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Quick action buttons - compact design
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButtonCompact(
                  svgPath: 'assets/icons/Shield.svg',
                  label: 'Check',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildQuickActionButtonCompact(
                  svgPath: 'assets/icons/video.svg',
                  label: 'Apps',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 6),
              // Referral - icon only
              _buildQuickActionIconOnly(
                svgPath: 'assets/icons/Users.svg',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Quick action button compact with icon + short label
  Widget _buildQuickActionButtonCompact({
    required String svgPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  svgPath,
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF0F172A),
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Quick action button with icon only (for Referral)
  Widget _buildQuickActionIconOnly({
    required String svgPath,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Center(
            child: SvgPicture.asset(
              svgPath,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF0F172A),
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReferralBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFFD3F8DF),
            Colors.white.withOpacity(0),
          ],
          stops: const [0, 0.22],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Logo - HourlyUGC
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 0.8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF69FFB4).withOpacity(0.18),
                  blurRadius: 39,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/images/logo_small.svg',
                width: 21,
                height: 21,
              ),
            ),
          ),
          const SizedBox(width: 13),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Earn \$25 with every referral',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Refer a friend to HourlyUGC',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          // Close button
          GestureDetector(
            onTap: () => setState(() => _showReferralBanner = false),
            child: const Icon(
              Icons.close,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsGrid(List<JobModel> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_off_outlined, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              'No jobs available',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(recentJobsProvider),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 0.85,
      ),
      itemCount: jobs.length,
      itemBuilder: (context, index) => _buildJobCard(jobs[index]),
    );
  }

  Widget _buildJobCard(JobModel job) {
    // Use real data - coverImage first, then companyLogo
    final imageUrl = job.coverImage ?? job.companyLogo;
    // Use real applicants count from Firestore (no fake fallback)
    final applicants = job.applicantsCount;
    
    return GestureDetector(
      onTap: () => context.push('/creator/jobs/${job.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    // Job image - Optimized with CachedNetworkImage for smooth loading
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: OptimizedImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: _buildJobPlaceholder(),
                        errorWidget: _buildJobPlaceholder(),
                      ),
                    ),
                    // Applicants count badge
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
                              applicants >= 1000 ? '${(applicants / 1000).toStringAsFixed(0)}k' : '$applicants',
                              style: GoogleFonts.inter(
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
            ),
            const SizedBox(height: 12),
            // Job info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF475569),
                          ),
                        ),
                        Text(
                          job.companyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '\$${job.budget.toStringAsFixed(0)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (job.paymentType != null)
                        Text(
                          _getPaymentTypeSuffix(job.paymentType!),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: const Color(0xFF475569),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Job placeholder with HourlyUGC logo - beautiful branding
  Widget _buildJobPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF10B981), Color(0xFF38EF7D)],
        ),
      ),
      child: Center(
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF050514).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SvgPicture.asset(
              'assets/images/logo_hourlyugc.svg',
              width: 34,
              height: 34,
            ),
          ),
        ),
      ),
    );
  }

  /// Get payment type suffix (matches Vue getPaymentTypeLabel)
  String _getPaymentTypeSuffix(String type) {
    switch (type.toLowerCase()) {
      case 'hourly':
        return '/h';
      case 'per-post':
      case 'perpost':
        return '/post';
      case 'monthly':
        return '/mo';
      case 'fixed':
        return '';
      default:
        return '';
    }
  }

  /// Bottom Navigation - Figma Node 33:2517 (Navbar-Glass)
  Widget _buildBottomNavigation() {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          // Blur background
          Positioned.fill(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Navigation bar - exact Figma properties
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 362, // Figma: width 362px
              padding: const EdgeInsets.all(8), // Figma: padding 8px
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(51), // Figma: rounded-[51px]
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF050514).withOpacity(0.15), // Figma: rgba(5,5,20,0.15)
                    blurRadius: 27.6, // Figma: 27.6px
                    offset: const Offset(0, 4), // Figma: 0px 4px
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Home - active with green gradient (Figma width: 114px)
                  _buildNavItemSvg(0, 'assets/icons/Navigation.svg', 'Home', isActive: _selectedNavIndex == 0),
                  // Jobs (Figma width: 77.333px)
                  _buildNavItemSvg(1, 'assets/icons/video.svg', null, isActive: _selectedNavIndex == 1),
                  // Chat (Figma width: 77.333px)
                  _buildNavItemSvg(2, 'assets/icons/Group 13.svg', null, isActive: _selectedNavIndex == 2),
                  // Wallet (Figma width: 77.333px)
                  _buildNavItemSvg(3, 'assets/icons/Vector-1.svg', null, isActive: _selectedNavIndex == 3),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Nav item with SVG icon - Figma exact properties
  /// Active: width 114px, border 5px rgba(255,255,255,0.35), radial gradient
  /// Inactive: width 77.333px, no background
  Widget _buildNavItemSvg(int index, String svgPath, String? label, {bool isActive = false}) {
    return Expanded(
      flex: isActive && label != null ? 2 : 1, // Active ~114px, Inactive ~77px
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedNavIndex = index);
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push('/creator/jobs');
              break;
            case 2:
              context.push('/creator/chat');
              break;
            case 3:
              context.push('/creator/payout');
              break;
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12), // Figma: padding 12px
          decoration: isActive
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(999), // Figma: rounded-[999px]
                  // Figma radial gradient: #9FF7C0 -> #45D27B -> #129C8D
                  gradient: const RadialGradient(
                    center: Alignment.bottomCenter,
                    radius: 1.5,
                    colors: [
                      Color(0xFF9FF7C0), // stop 0: Light mint
                      Color(0xFF45D27B), // stop 0.34: Emerald
                      Color(0xFF129C8D), // stop 1: Teal
                    ],
                    stops: [0.0, 0.34, 1.0],
                  ),
                  // Figma: border 5px rgba(255,255,255,0.35)
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 5,
                  ),
                  // Figma shadows
                  boxShadow: [
                    // shadow-[0px_0px_25.7px_0px_rgba(16,185,129,0.5)]
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(0.5),
                      blurRadius: 25.7,
                    ),
                    // shadow-[0px_3px_39.1px_0px_rgba(105,255,180,0.18)]
                    BoxShadow(
                      color: const Color(0xFF69FFB4).withOpacity(0.18),
                      blurRadius: 39.1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                )
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                svgPath,
                width: 20, // Reduced size
                height: 20,
                colorFilter: ColorFilter.mode(
                  isActive ? const Color(0xFF022C22) : const Color(0xFF64748B),
                  BlendMode.srcIn,
                ),
              ),
              if (isActive && label != null) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF022C22),
                      letterSpacing: -0.18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/creator/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/creator/settings');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                // Reset onboarding state before logout
                ref.read(onboardingStateProvider.notifier).reset();
                ref.read(isInOnboardingFlowProvider.notifier).state = false;
                ref.read(registrationJustCompletedProvider.notifier).state = false;
                
                await ref.read(loginProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/onboarding');
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Check if there were earnings on a specific day (0 = today, 1 = yesterday, etc.)
  bool _hasEarningsForDay(int daysAgo, AsyncValue currentUser) {
    // TODO: Fetch actual earnings history from completed jobs
    // For now, return a pattern for demo (you can replace with real data)
    // This should check completed jobs/applications for earnings on that specific day
    return currentUser.maybeWhen(
      data: (user) {
        // If balance is 0, all dots (no earnings)
        if (user?.balance == null || (user!.balance ?? 0.0) == 0.0) {
          return false;
        }
        // Simple pattern: show earnings on some days (can be replaced with real data)
        // Days with earnings: 0, 2, 5, 8, 12, 15, 18 (today and some past days)
        return [0, 2, 5, 8, 12, 15, 18].contains(daysAgo);
      },
      orElse: () => false,
    );
  }
}
