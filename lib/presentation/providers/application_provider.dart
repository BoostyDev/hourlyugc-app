import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/application_repository.dart';
import '../../data/models/application_model.dart';
import 'auth_provider.dart';

/// Application repository provider
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepository();
});

/// My applications provider (for current user)
final myApplicationsProvider = StreamProvider<List<ApplicationModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) {
    return Stream.value([]);
  }

  final appRepo = ref.watch(applicationRepositoryProvider);
  return appRepo.watchMyApplications(userId);
});

/// Application stats provider
final applicationStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) {
    return {
      'total': 0,
      'pending': 0,
      'accepted': 0,
      'rejected': 0,
    };
  }

  final appRepo = ref.watch(applicationRepositoryProvider);
  return appRepo.getApplicationStats(userId);
});

/// Applicants count provider for a specific job
final jobApplicantsCountProvider = FutureProvider.family<int, String>((ref, jobId) async {
  final appRepo = ref.watch(applicationRepositoryProvider);
  return appRepo.getApplicantsCountForJob(jobId);
});

/// Apply to job provider
final applyToJobProvider = StateNotifierProvider<ApplyToJobNotifier, AsyncValue<void>>((ref) {
  return ApplyToJobNotifier(
    ref.read(applicationRepositoryProvider),
    ref.read(authStateProvider).value?.uid,
  );
});

class ApplyToJobNotifier extends StateNotifier<AsyncValue<void>> {
  final ApplicationRepository _repository;
  final String? _userId;

  ApplyToJobNotifier(this._repository, this._userId) 
      : super(const AsyncValue.data(null));

  Future<bool> apply({
    required String jobId,
    required String employerId,
    String? coverLetter,
    String? jobTitle,
    String? companyName,
  }) async {
    if (_userId == null) {
      state = AsyncValue.error('Not logged in', StackTrace.current);
      return false;
    }

    state = const AsyncValue.loading();
    try {
      await _repository.applyToJob(
        jobId: jobId,
        applicantId: _userId,
        employerId: employerId,
        coverLetter: coverLetter,
        jobTitle: jobTitle,
        companyName: companyName,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> hasApplied(String jobId) async {
    if (_userId == null) return false;
    return _repository.hasApplied(jobId: jobId, applicantId: _userId);
  }
}

