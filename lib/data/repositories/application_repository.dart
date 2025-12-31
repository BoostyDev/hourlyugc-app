import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/application_model.dart';
import '../../core/constants/app_constants.dart';

/// Application repository
class ApplicationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  /// Apply to a job
  Future<bool> applyToJob({
    required String jobId,
    required String applicantId,
    required String employerId,
    String? coverLetter,
    String? jobTitle,
    String? companyName,
  }) async {
    try {
      // Check if already applied
      final existingApp = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('jobPostId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: applicantId)
          .limit(1)
          .get();

      if (existingApp.docs.isNotEmpty) {
        throw Exception('You have already applied to this job');
      }

      // Get applicant info from user profile (to avoid "Unknown Applicant")
      String? applicantName;
      String? applicantEmail;
      String? applicantPhotoURL;
      
      try {
        final userDoc = await _firestore
            .collection('users')
            .doc(applicantId)
            .get(const GetOptions(source: Source.serverAndCache));
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          // Get name (like Vue does)
          applicantName = userData['fullName'] as String? ??
              (userData['firstName'] != null && userData['lastName'] != null
                  ? '${userData['firstName']} ${userData['lastName']}'
                  : null) ??
              userData['displayName'] as String? ??
              userData['firstName'] as String? ??
              userData['name'] as String?;
          
          // Get email
          applicantEmail = userData['email'] as String?;
          
          // Get photo
          applicantPhotoURL = userData['photoURL'] as String? ??
              userData['photoUrl'] as String? ??
              userData['photo'] as String?;
        }
      } catch (e) {
        // If we can't get user info, continue without it (fallback to applicantId)
        // Could not fetch applicant info - continue without it
      }

      // Create application
      final appId = _uuid.v4();
      final application = ApplicationModel(
        id: appId,
        jobId: jobId,
        applicantId: applicantId,
        employerId: employerId,
        status: 'pending',
        coverLetter: coverLetter,
        appliedAt: DateTime.now(),
        jobTitle: jobTitle,
        companyName: companyName,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
        applicantPhotoURL: applicantPhotoURL,
      );

      await _firestore
          .collection(AppConstants.applicationsCollection)
          .doc(appId)
          .set(application.toJson());

      return true;
    } catch (e) {
      throw Exception('Failed to apply: $e');
    }
  }

  /// Get creator's applications
  Future<List<ApplicationModel>> getMyApplications(String applicantId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('applicantId', isEqualTo: applicantId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ApplicationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      throw Exception('Failed to load applications: $e');
    }
  }

  /// Stream creator's applications (real-time)
  Stream<List<ApplicationModel>> watchMyApplications(String applicantId) {
    return _firestore
        .collection(AppConstants.applicationsCollection)
        .where('applicantId', isEqualTo: applicantId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromJson({...doc.data(), 'id': doc.id}))
            .toList());
  }

  /// Get application by ID
  Future<ApplicationModel?> getApplicationById(String applicationId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.applicationsCollection)
          .doc(applicationId)
          .get();

      if (!doc.exists) return null;

      return ApplicationModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      return null;
    }
  }

  /// Check if user has applied to a job
  Future<bool> hasApplied({
    required String jobId,
    required String applicantId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('jobPostId', isEqualTo: jobId)
          .where('applicantId', isEqualTo: applicantId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get applicants count for a job (real-time from applications collection)
  Future<int> getApplicantsCountForJob(String jobId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('jobPostId', isEqualTo: jobId)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      // Silently return 0 on error - the job.applicantsCount field is the fallback
      return 0;
    }
  }

  /// Get application stats for creator
  Future<Map<String, int>> getApplicationStats(String applicantId) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('applicantId', isEqualTo: applicantId)
          .get();

      int total = snapshot.docs.length;
      int pending = 0;
      int accepted = 0;
      int rejected = 0;

      for (var doc in snapshot.docs) {
        final status = doc.data()['status'] as String?;
        if (status == 'pending') pending++;
        if (status == 'accepted') accepted++;
        if (status == 'rejected') rejected++;
      }

      return {
        'total': total,
        'pending': pending,
        'accepted': accepted,
        'rejected': rejected,
      };
    } catch (e) {
      return {
        'total': 0,
        'pending': 0,
        'accepted': 0,
        'rejected': 0,
      };
    }
  }
}

