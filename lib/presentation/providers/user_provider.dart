import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/user_repository.dart';
import 'auth_provider.dart';

/// User repository provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

/// Creator stats provider
final creatorStatsProvider = FutureProvider<CreatorStats>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.value?.uid;
  
  if (userId == null) {
    return CreatorStats(
      applications: 0,
      savedJobs: 0,
      profileViews: 0,
    );
  }

  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getCreatorStats(userId);
});

