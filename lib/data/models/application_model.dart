import 'package:cloud_firestore/cloud_firestore.dart';

/// Application model
class ApplicationModel {
  final String id;
  final String jobId;
  final String applicantId; // Creator userId
  final String employerId;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? coverLetter;
  final DateTime appliedAt;
  final String? jobTitle; // Denormalized for display
  final String? companyName; // Denormalized for display
  final String? applicantName; // Applicant name for employer view
  final String? applicantEmail; // Applicant email for employer view
  final String? applicantPhotoURL; // Applicant photo for employer view

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.applicantId,
    required this.employerId,
    required this.status,
    this.coverLetter,
    required this.appliedAt,
    this.jobTitle,
    this.companyName,
    this.applicantName,
    this.applicantEmail,
    this.applicantPhotoURL,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      jobId: json['jobPostId'] as String, // Note: jobPostId in Firestore
      applicantId: json['applicantId'] as String,
      employerId: json['employerId'] as String,
      status: json['status'] as String? ?? 'pending',
      coverLetter: json['coverLetter'] as String?,
      appliedAt: (json['appliedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jobTitle: json['jobTitle'] as String?,
      companyName: json['companyName'] as String?,
      applicantName: json['applicantName'] as String?,
      applicantEmail: json['applicantEmail'] as String?,
      applicantPhotoURL: json['applicantPhotoURL'] as String? ?? json['applicantPhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobPostId': jobId,
      'applicantId': applicantId,
      'employerId': employerId,
      'status': status,
      'coverLetter': coverLetter,
      'appliedAt': Timestamp.fromDate(appliedAt),
      'jobTitle': jobTitle,
      'companyName': companyName,
      'applicantName': applicantName,
      'applicantEmail': applicantEmail,
      'applicantPhotoURL': applicantPhotoURL,
    };
  }

  ApplicationModel copyWith({
    String? id,
    String? jobId,
    String? applicantId,
    String? employerId,
    String? status,
    String? coverLetter,
    DateTime? appliedAt,
    String? jobTitle,
    String? companyName,
    String? applicantName,
    String? applicantEmail,
    String? applicantPhotoURL,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      applicantId: applicantId ?? this.applicantId,
      employerId: employerId ?? this.employerId,
      status: status ?? this.status,
      coverLetter: coverLetter ?? this.coverLetter,
      appliedAt: appliedAt ?? this.appliedAt,
      jobTitle: jobTitle ?? this.jobTitle,
      companyName: companyName ?? this.companyName,
      applicantName: applicantName ?? this.applicantName,
      applicantEmail: applicantEmail ?? this.applicantEmail,
      applicantPhotoURL: applicantPhotoURL ?? this.applicantPhotoURL,
    );
  }
}

