import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/job_provider.dart';
import '../../widgets/job_card.dart';
import '../../widgets/skeleton_loaders.dart';

/// Jobs listing screen
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load jobs on init
    Future.microtask(() {
      ref.read(allJobsProvider.notifier).loadJobs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    ref.read(allJobsProvider.notifier).searchJobs(query);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterBottomSheet(
        onApply: (location, minBudget, maxBudget, jobType) {
          ref.read(allJobsProvider.notifier).filterJobs(
            location: location,
            minBudget: minBudget,
            maxBudget: maxBudget,
            jobType: jobType,
          );
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(allJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Jobs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                      )
                    : null,
              ),
              onSubmitted: _handleSearch,
            ),
          ),

          // Jobs List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(allJobsProvider.notifier).loadJobs(forceRefresh: true);
              },
              child: jobsAsync.when(
                data: (jobs) {
                  if (jobs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No jobs found'),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    // Add cacheExtent for smoother scrolling
                    cacheExtent: 500,
                    itemBuilder: (context, index) {
                      // Use RepaintBoundary for better performance
                      return RepaintBoundary(
                        child: JobCard(
                          job: jobs[index],
                          onTap: () => context.push('/creator/jobs/${jobs[index].id}'),
                        ),
                      );
                    },
                  );
                },
                // Use skeleton loaders instead of spinner
                loading: () => const JobsListSkeleton(itemCount: 5),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(allJobsProvider.notifier).loadJobs(forceRefresh: true);
                        },
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
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final Function(String?, double?, double?, String?) onApply;

  const _FilterBottomSheet({required this.onApply});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  final _locationController = TextEditingController();
  double? _minBudget;
  double? _maxBudget;
  String? _jobType;

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Jobs',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min Budget',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _minBudget = double.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max Budget',
                      border: OutlineInputBorder(),
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _maxBudget = double.tryParse(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () {
                  widget.onApply(
                    _locationController.text.trim().isNotEmpty 
                        ? _locationController.text.trim() 
                        : null,
                    _minBudget,
                    _maxBudget,
                    _jobType,
                  );
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

