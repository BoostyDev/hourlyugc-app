import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/job_repository.dart';
import '../../data/models/job_model.dart';

/// Job repository provider (singleton)
final jobRepositoryProvider = Provider<JobRepository>((ref) {
  return JobRepository();
});

/// Recent jobs provider - Uses STREAM for real-time updates (like Vue onSnapshot)
/// This makes the dashboard feel smooth and instant
final recentJobsProvider = StreamProvider<List<JobModel>>((ref) {
  final jobRepo = ref.watch(jobRepositoryProvider);
  return jobRepo.watchRecentJobs(limit: 5);
});

/// All jobs stream provider - Real-time like Vue
final allJobsStreamProvider = StreamProvider<List<JobModel>>((ref) {
  final jobRepo = ref.watch(jobRepositoryProvider);
  return jobRepo.watchJobs(limit: 20);
});

/// All jobs provider with search/filter capability
final allJobsProvider = StateNotifierProvider<JobsNotifier, AsyncValue<List<JobModel>>>((ref) {
  return JobsNotifier(ref.read(jobRepositoryProvider), ref);
});

class JobsNotifier extends StateNotifier<AsyncValue<List<JobModel>>> {
  final JobRepository _repository;
  StreamSubscription<List<JobModel>>? _subscription;
  String? _currentSearchQuery;
  
  JobsNotifier(this._repository, Ref ref) : super(const AsyncValue.loading()) {
    _subscribeToJobs();
  }

  /// Subscribe to real-time job updates (like Vue's onSnapshot)
  void _subscribeToJobs() {
    _subscription?.cancel();
    _subscription = _repository.watchJobs(limit: 20).listen(
      (jobs) {
        // Apply local search filter if active
        if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
          final filtered = jobs.where((job) =>
            job.title.toLowerCase().contains(_currentSearchQuery!.toLowerCase()) ||
            job.companyName.toLowerCase().contains(_currentSearchQuery!.toLowerCase())
          ).toList();
          state = AsyncValue.data(filtered);
        } else {
          state = AsyncValue.data(jobs);
        }
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  Future<void> loadJobs({bool forceRefresh = false}) async {
    _currentSearchQuery = null;
    if (forceRefresh) {
      _repository.clearCache();
    }
    // Re-subscribe to get fresh data
    _subscribeToJobs();
  }

  Future<void> searchJobs(String query) async {
    _currentSearchQuery = query;
    
    if (query.isEmpty) {
      _subscribeToJobs();
      return;
    }
    
    // Show loading briefly
    state = const AsyncValue.loading();
    
    // Search via Firestore (for server-side prefix search)
    state = await AsyncValue.guard(() => _repository.searchJobs(query));
  }

  Future<void> filterJobs({
    String? location,
    double? minBudget,
    double? maxBudget,
    String? jobType,
  }) async {
    _subscription?.cancel();
    state = const AsyncValue.loading();
    
    // Use stream for filtered results
    _subscription = _repository.watchFilteredJobs(
      location: location,
      jobType: jobType,
      limit: 20,
    ).listen(
      (jobs) {
        // Apply budget filter client-side
        var filtered = jobs;
        if (minBudget != null) {
          filtered = filtered.where((job) => job.budget >= minBudget).toList();
        }
        if (maxBudget != null) {
          filtered = filtered.where((job) => job.budget <= maxBudget).toList();
        }
        state = AsyncValue.data(filtered);
      },
      onError: (error, stack) {
        state = AsyncValue.error(error, stack);
      },
    );
  }

  /// Load more jobs (pagination)
  Future<void> loadMore() async {
    final currentJobs = state.valueOrNull ?? [];
    final moreJobs = await _repository.loadMoreJobs();
    state = AsyncValue.data([...currentJobs, ...moreJobs]);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Single job stream provider - Real-time updates
final jobStreamProvider = StreamProvider.family<JobModel?, String>((ref, jobId) {
  final jobRepo = ref.watch(jobRepositoryProvider);
  return jobRepo.watchJob(jobId);
});

/// Single job provider (one-time fetch, for backwards compatibility)
final jobProvider = FutureProvider.family<JobModel?, String>((ref, jobId) async {
  final jobRepo = ref.watch(jobRepositoryProvider);
  return jobRepo.getJobById(jobId);
});

