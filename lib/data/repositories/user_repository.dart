import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../../core/constants/app_constants.dart';

/// User repository
class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Get user data
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) return null;

      return UserModel.fromJson({...doc.data()!, 'uid': doc.id});
    } catch (e) {
      return null;
    }
  }

  /// Stream user data (real-time)
  Stream<UserModel?> watchUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromJson({...doc.data()!, 'uid': doc.id});
    });
  }

  /// Update user profile
  Future<bool> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload profile photo
  Future<String?> uploadProfilePhoto(String uid, File imageFile) async {
    try {
      final ref = _storage
          .ref()
          .child('${AppConstants.profilePhotosPath}/$uid/profile.jpg');

      await ref.putFile(imageFile);
      final downloadUrl = await ref.getDownloadURL();

      // Update user document
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'profileImage': downloadUrl});

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Get creator stats for dashboard
  Future<CreatorStats> getCreatorStats(String uid) async {
    try {
      // Get applications count
      final applicationsSnapshot = await _firestore
          .collection(AppConstants.applicationsCollection)
          .where('applicantId', isEqualTo: uid)
          .get();

      // Get saved jobs count (favorites)
      final savedJobsSnapshot = await _firestore
          .collection('favorites')
          .where('userId', isEqualTo: uid)
          .get();

      // Get profile views count
      final profileViewsSnapshot = await _firestore
          .collection('profileViews')
          .where('viewedUserId', isEqualTo: uid)
          .get();

      return CreatorStats(
        applications: applicationsSnapshot.docs.length,
        savedJobs: savedJobsSnapshot.docs.length,
        profileViews: profileViewsSnapshot.docs.length,
      );
    } catch (e) {
      return CreatorStats(
        applications: 0,
        savedJobs: 0,
        profileViews: 0,
      );
    }
  }

  /// Update social media links
  Future<bool> updateSocialMedia(String uid, SocialMedia socialMedia) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'socialMedia': socialMedia.toJson()});
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// Creator stats model
class CreatorStats {
  final int applications;
  final int savedJobs;
  final int profileViews;

  CreatorStats({
    required this.applications,
    required this.savedJobs,
    required this.profileViews,
  });
}

