import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../../core/constants/app_constants.dart';

/// Job repository - Optimized for mobile performance
/// Uses Firestore's offline persistence + real-time streams for smooth UX
class JobRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for pagination
  DocumentSnapshot? _lastDocument;
  List<JobModel> _cachedJobs = [];

  /// Get active jobs with pagination - Uses cache first, then network
  Future<List<JobModel>> getJobs({
    int limit = 20,
    DocumentSnapshot? startAfter,
    bool forceRefresh = false,
  }) async {
    try {
      // Return cached data immediately if available (for instant UI)
      if (!forceRefresh && _cachedJobs.isNotEmpty && startAfter == null) {
        return _cachedJobs;
      }

      Query query = _firestore
          .collection(AppConstants.jobPostsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Use cache-first strategy for better performance
      final snapshot = await query.get(
        const GetOptions(source: Source.serverAndCache),
      );

      final jobs = snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Update cache
      if (startAfter == null) {
        _cachedJobs = jobs;
      } else {
        _cachedJobs.addAll(jobs);
      }
      
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      return jobs;
    } catch (e) {
      // On error, try to return cached data
      if (_cachedJobs.isNotEmpty) {
        return _cachedJobs;
      }
      throw Exception('Failed to load jobs: $e');
    }
  }

  /// Get recent jobs (for dashboard) - OPTIMIZED with cache
  Future<List<JobModel>> getRecentJobs({int limit = 5}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.jobPostsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load recent jobs: $e');
    }
  }

  /// Stream recent jobs (real-time like Vue's onSnapshot) - SMOOTH UX
  Stream<List<JobModel>> watchRecentJobs({int limit = 5}) {
    return _firestore
        .collection(AppConstants.jobPostsCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final jobs = snapshot.docs
              .map((doc) => JobModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          // Enrich each job with real applicants count
          return await Future.wait(
            jobs.map((job) => _enrichJobWithApplicantsCount(job)),
          );
        });
  }

  /// Get job by ID with cache - enriched with employer info
  Future<JobModel?> getJobById(String jobId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.jobPostsCollection)
          .doc(jobId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!doc.exists) return null;

      final job = JobModel.fromJson({...doc.data()!, 'id': doc.id});
      // Enrich with employer info (like Vue)
      return await _enrichJobWithEmployerInfo(job);
    } catch (e) {
      return null;
    }
  }

  /// Stream single job (real-time) - enriched with employer info and real applicants count
  Stream<JobModel?> watchJob(String jobId) {
    return _firestore
        .collection(AppConstants.jobPostsCollection)
        .doc(jobId)
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) return null;
          final job = JobModel.fromJson({...doc.data()!, 'id': doc.id});
          // Enrich with employer info if logo is missing
          final enrichedJob = await _enrichJobWithEmployerInfo(job);
          // Enrich with real applicants count from applications collection
          return await _enrichJobWithApplicantsCount(enrichedJob);
        });
  }

  /// Enrich job with employer info (like Vue's getCompanyInfo)
  Future<JobModel> _enrichJobWithEmployerInfo(JobModel job) async {
    // If job already has logo, no need to fetch employer
    if (job.companyLogo != null && job.companyLogo!.isNotEmpty) {
      return job;
    }

    // Try to get employer info
    if (job.employerId.isEmpty) return job;

    try {
      final employerDoc = await _firestore
          .collection('users')
          .doc(job.employerId)
          .get(const GetOptions(source: Source.serverAndCache));

      if (!employerDoc.exists) return job;

      final data = employerDoc.data()!;
      
      // Get company logo from employer (like Vue)
      String? companyLogo = data['companyLogo'] as String? ??
          data['logo'] as String? ??
          data['photoURL'] as String? ??
          data['photoUrl'] as String? ??
          (data['company'] as Map<String, dynamic>?)?['logo'] as String?;
      
      // Get company name from employer if missing
      String? companyName = job.companyName.isEmpty || job.companyName == 'Unknown Company'
          ? (data['companyName'] as String? ??
             (data['company'] as Map<String, dynamic>?)?['name'] as String? ??
             data['businessName'] as String?)
          : null;
      
      // Get location from employer if missing
      String? location = job.location.isEmpty || job.location == 'Remote'
          ? (data['location'] is Map 
              ? _formatLocation(data['location'] as Map<String, dynamic>)
              : data['location'] as String?)
          : null;

      return job.copyWith(
        companyLogo: companyLogo ?? job.companyLogo,
        companyName: companyName ?? job.companyName,
        location: location ?? job.location,
      );
    } catch (e) {
      // On error, return original job
      return job;
    }
  }

  /// Format location from employer data (Vue format)
  String _formatLocation(Map<String, dynamic> locationData) {
    final city = locationData['city'] as String?;
    final state = locationData['state'] as String?;
    final country = locationData['country'] as String?;
    
    final parts = <String>[];
    if (city != null && city.isNotEmpty) parts.add(city);
    if (state != null && state.isNotEmpty) parts.add(state);
    if (country != null && country.isNotEmpty) parts.add(country);
    
    return parts.isNotEmpty ? parts.join(', ') : 'Remote';
  }

  /// Enrich job with real applicants count from applications collection + views/clicks
  Future<JobModel> _enrichJobWithApplicantsCount(JobModel job) async {
    try {
      // Count applications for this job (like Vue's getJobApplicationCount)
      final applicationsSnapshot = await _firestore
          .collection('applications')
          .where('jobId', isEqualTo: job.id)
          .get(const GetOptions(source: Source.serverAndCache));
      
      // Also check jobPostId for compatibility
      final applicationsSnapshot2 = await _firestore
          .collection('applications')
          .where('jobPostId', isEqualTo: job.id)
          .get(const GetOptions(source: Source.serverAndCache));
      
      // Combine both queries (remove duplicates by application ID)
      final allApplicationIds = <String>{};
      int applicantsCount = 0;
      
      for (var doc in applicationsSnapshot.docs) {
        if (!allApplicationIds.contains(doc.id)) {
          allApplicationIds.add(doc.id);
          applicantsCount++;
        }
      }
      
      for (var doc in applicationsSnapshot2.docs) {
        if (!allApplicationIds.contains(doc.id)) {
          allApplicationIds.add(doc.id);
          applicantsCount++;
        }
      }
      
      // Get views/clicks from job document if available
      final jobData = await _firestore
          .collection(AppConstants.jobPostsCollection)
          .doc(job.id)
          .get(const GetOptions(source: Source.serverAndCache));
      
      int views = 0;
      if (jobData.exists) {
        final data = jobData.data()!;
        if (data['views'] is int) views = data['views'] as int;
        else if (data['views'] is num) views = (data['views'] as num).toInt();
        else if (data['viewCount'] is int) views = data['viewCount'] as int;
        else if (data['viewCount'] is num) views = (data['viewCount'] as num).toInt();
        else if (data['clicks'] is int) views = data['clicks'] as int;
        else if (data['clicks'] is num) views = (data['clicks'] as num).toInt();
      }
      
      // Return job with updated applicants count (applicants + views for more attractive number)
      return job.copyWith(applicantsCount: applicantsCount + views);
    } catch (e) {
      // On error, return original job
      return job;
    }
  }

  /// Stream all jobs (real-time like Vue's onSnapshot) - with real applicants count
  Stream<List<JobModel>> watchJobs({int limit = 20}) {
    return _firestore
        .collection(AppConstants.jobPostsCollection)
        .where('status', isEqualTo: 'active')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .asyncMap((snapshot) async {
          final jobs = snapshot.docs
              .map((doc) => JobModel.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
          // Enrich each job with real applicants count
          return await Future.wait(
            jobs.map((job) => _enrichJobWithApplicantsCount(job)),
          );
        });
  }

  /// Search jobs by title or company
  Future<List<JobModel>> searchJobs(String query) async {
    try {
      // Note: Firestore doesn't support full-text search
      // This is a simple search by title prefix
      final snapshot = await _firestore
          .collection(AppConstants.jobPostsCollection)
          .where('status', isEqualTo: 'active')
          .orderBy('title')
          .startAt([query])
          .endAt(['$query\uf8ff'])
          .limit(20)
          .get(const GetOptions(source: Source.serverAndCache));

      return snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to search jobs: $e');
    }
  }

  /// Filter jobs with stream (real-time updates)
  Stream<List<JobModel>> watchFilteredJobs({
    String? location,
    String? jobType,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(AppConstants.jobPostsCollection)
        .where('status', isEqualTo: 'active');

    if (location != null && location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    if (jobType != null && jobType.isNotEmpty) {
      query = query.where('jobType', isEqualTo: jobType);
    }

    return query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JobModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
            .toList());
  }

  /// Filter jobs by location, budget, etc. (one-time fetch)
  Future<List<JobModel>> filterJobs({
    String? location,
    double? minBudget,
    double? maxBudget,
    String? jobType,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.jobPostsCollection)
          .where('status', isEqualTo: 'active');

      if (location != null && location.isNotEmpty) {
        query = query.where('location', isEqualTo: location);
      }

      if (jobType != null && jobType.isNotEmpty) {
        query = query.where('jobType', isEqualTo: jobType);
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      final snapshot = await query.get(
        const GetOptions(source: Source.serverAndCache),
      );

      var jobs = snapshot.docs
          .map((doc) => JobModel.fromJson({...doc.data() as Map<String, dynamic>, 'id': doc.id}))
          .toList();

      // Filter by budget client-side
      if (minBudget != null) {
        jobs = jobs.where((job) => job.budget >= minBudget).toList();
      }
      if (maxBudget != null) {
        jobs = jobs.where((job) => job.budget <= maxBudget).toList();
      }

      return jobs;
    } catch (e) {
      throw Exception('Failed to filter jobs: $e');
    }
  }

  /// Load more jobs (pagination)
  Future<List<JobModel>> loadMoreJobs({int limit = 20}) async {
    if (_lastDocument == null) {
      return getJobs(limit: limit);
    }
    return getJobs(limit: limit, startAfter: _lastDocument);
  }

  /// Clear cache (for pull-to-refresh)
  void clearCache() {
    _cachedJobs.clear();
    _lastDocument = null;
  }
}

