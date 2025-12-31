import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../providers/job_provider.dart';
import '../../../data/models/job_model.dart';
import '../../widgets/optimized_image.dart';

/// Jobs Screen - Figma Node 33:3128
/// Stacked cards design with swipe functionality
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'For You';
  final List<String> _filters = ['For You', 'All', 'Applied', 'Saved'];
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(allJobsProvider.notifier).loadJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSwipeLeft() {
    final jobs = ref.read(allJobsProvider).valueOrNull ?? [];
    if (_currentCardIndex < jobs.length - 1) {
      setState(() {
        _currentCardIndex++;
      });
    } else {
      // Loop back to first card
      setState(() {
        _currentCardIndex = 0;
      });
    }
  }

  void _onSwipeRight() {
    final jobs = ref.read(allJobsProvider).valueOrNull ?? [];
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
      });
    } else {
      // Loop to last card
      setState(() {
        _currentCardIndex = jobs.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(allJobsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar Row
            _buildSearchBar(),
            
            // Filter Tabs
            _buildFilterTabs(jobsAsync),
            
            // Jobs Cards Stack
            Expanded(
              child: jobsAsync.when(
                data: (jobs) => _buildCardStack(jobs),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF10B981)),
                ),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
                      const SizedBox(height: 16),
                      Text('Error loading jobs', style: GoogleFonts.plusJakartaSans()),
                      TextButton(
                        onPressed: () => ref.read(allJobsProvider.notifier).loadJobs(forceRefresh: true),
                        child: const Text('Retry'),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    'assets/icons/chat_search_icon.svg',
                    width: 22,
                    height: 22,
                    colorFilter: const ColorFilter.mode(Color(0xFF94A3B8), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                          letterSpacing: -0.18,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF0F172A),
                      ),
                      onSubmitted: (query) {
                        ref.read(allJobsProvider.notifier).searchJobs(query);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Sort Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/SortAscending.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Filter Button
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF050514).withOpacity(0.1),
                  blurRadius: 35,
                ),
              ],
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/Filter.svg',
                width: 20,
                height: 20,
                colorFilter: const ColorFilter.mode(Color(0xFF0F172A), BlendMode.srcIn),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(AsyncValue<List<JobModel>> jobsAsync) {
    final jobCount = jobsAsync.valueOrNull?.length ?? 0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        ),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            int count = 0;
            if (filter == 'All') count = jobCount;
            if (filter == 'Applied') count = 10;
            if (filter == 'Saved') count = 1;
            
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedFilter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF050514).withOpacity(0.1),
                              blurRadius: 35,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          filter,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                            letterSpacing: -0.16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (filter != 'For You' && count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: Colors.white,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCardStack(List<JobModel> jobs) {
    if (jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    // Ensure current index is valid
    if (_currentCardIndex >= jobs.length) {
      _currentCardIndex = 0;
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            _onSwipeLeft();
          } else if (details.primaryVelocity! > 200) {
            _onSwipeRight();
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Show 3 cards stacked (bottom to top)
            for (int i = 2; i >= 0; i--)
              if (_currentCardIndex + i < jobs.length)
                _buildStackedCard(
                  jobs[_currentCardIndex + i],
                  stackIndex: i,
                  isTop: i == 0,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedCard(JobModel job, {required int stackIndex, required bool isTop}) {
    // Calculate offset and scale for stacking effect
    final double topOffset = stackIndex * 60.0; // Increased offset for visible stacking
    final double scale = 1.0 - (stackIndex * 0.02);
    
    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: isTop ? () => context.push('/creator/jobs/${job.id}') : null,
          child: _JobCard(
            job: job,
            isTop: isTop,
            onTap: () => context.push('/creator/jobs/${job.id}'),
          ),
        ),
      ),
    );
  }
}

/// Job Card - Figma design with gradient pills
class _JobCard extends StatelessWidget {
  final JobModel job;
  final bool isTop;
  final VoidCallback onTap;

  const _JobCard({
    required this.job, 
    required this.isTop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FA),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF050514).withOpacity(isTop ? 0.15 : 0.1),
            blurRadius: isTop ? 15 : 27.6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Pills and buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pills
                    Row(
                      children: [
                        // Content Creator pill with gradient
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFF5D0FE), Color(0xFFDB2777)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF080616).withOpacity(0.1),
                                blurRadius: 5.9,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            'Content Creator',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Platform pill
                        Container(
                          height: 24,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                          ),
                          child: SvgPicture.asset(
                            'assets/icons/tiktok_layer1.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ],
                    ),
                    // Share and Love buttons
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/Share.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF050514).withOpacity(0.1),
                                blurRadius: 35,
                              ),
                            ],
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/Love.svg',
                              width: 16,
                              height: 16,
                              colorFilter: const ColorFilter.mode(Color(0xFF0F172A), BlendMode.srcIn),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Title and price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        job.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                            '/h',
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
                const SizedBox(height: 2),
                
                // Applied count, company, location row
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
                    _buildDot(),
                    if (job.companyLogo != null) ...[
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: OptimizedImage(
                            imageUrl: job.companyLogo!,
                            width: 20,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Flexible(
                      child: Text(
                        job.companyName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: const Color(0xFF64748B),
                          letterSpacing: -0.16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _buildDot(),
                    Text(
                      job.location,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                        letterSpacing: -0.16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  job.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                    letterSpacing: -0.16,
                    height: 1.43,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Job Image
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: job.coverImage != null && job.coverImage!.isNotEmpty
                  ? OptimizedImage(
                      imageUrl: job.coverImage!,
                      width: double.infinity,
                      height: 168,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 168,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.image, size: 48, color: Color(0xFF94A3B8)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(21.75),
      ),
    );
  }
}
