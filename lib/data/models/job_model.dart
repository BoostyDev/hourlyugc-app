import 'package:cloud_firestore/cloud_firestore.dart';

/// Job Post model - Compatible with Vue web app
class JobModel {
  /// Strip HTML tags from text
  static String _stripHtml(String htmlString) {
    // Remove HTML tags
    final withoutTags = htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode common HTML entities
    return withoutTags
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .trim();
  }

  final String id;
  final String title;
  final String description;
  final double budget; // Maps from payAmount in Firestore
  final String location;
  final String companyName; // Maps from company in Firestore
  final String? companyLogo;
  final String? coverImage; // Job cover image if available
  final String employerId;
  final String status; // 'active', 'closed', 'draft'
  final DateTime createdAt;
  final List<String>? requirements;
  final List<String>? tags;
  final String? jobType; // 'ugc', 'content', 'influencer'
  final String? paymentType; // 'fixed', 'hourly', etc.
  final String? experienceLevel; // 'beginner', 'intermediate', 'advanced', 'professional'
  final int applicantsCount; // Number of applicants
  final bool isSaved; // Local state, not in Firestore

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    required this.budget,
    required this.location,
    required this.companyName,
    this.companyLogo,
    this.coverImage,
    required this.employerId,
    required this.status,
    required this.createdAt,
    this.requirements,
    this.tags,
    this.jobType,
    this.paymentType,
    this.experienceLevel,
    this.applicantsCount = 0,
    this.isSaved = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Handle budget/payAmount field mapping (Vue uses payAmount, we use budget)
    double parseBudget() {
      if (json['budget'] != null) {
        return (json['budget'] as num).toDouble();
      }
      if (json['payAmount'] != null) {
        final payAmount = json['payAmount'];
        if (payAmount is num) return payAmount.toDouble();
        if (payAmount is String) return double.tryParse(payAmount) ?? 0.0;
      }
      if (json['pay'] != null) {
        final pay = json['pay'];
        if (pay is num) return pay.toDouble();
        if (pay is String) return double.tryParse(pay) ?? 0.0;
      }
      return 0.0;
    }
    
    // Handle company/companyName field mapping
    String parseCompanyName() {
      return (json['companyName'] ?? json['company'] ?? 'Unknown Company') as String;
    }
    
    // Parse cover image - could be in different fields (Vue uses jobPhoto)
    String? parseCoverImage() {
      return json['jobPhoto'] as String? ??
             json['coverImage'] as String? ??
             json['image'] as String? ??
             json['thumbnail'] as String? ??
             json['mediaUrl'] as String?;
    }
    
    // Parse company logo - check multiple fields (Vue gets from employer profile too)
    String? parseCompanyLogo() {
      return json['companyLogo'] as String? ??
             json['logo'] as String? ??
             json['photoURL'] as String? ??
             json['photoUrl'] as String? ??
             json['employerPhoto'] as String? ??
             json['employerLogo'] as String?;
    }
    
    // Parse applicants count - includes historical applicants + views/clicks
    int parseApplicantsCount() {
      // Get base applicants count
      int applicants = 0;
      if (json['applicantCount'] is int) applicants = json['applicantCount'] as int;
      else if (json['applicantCount'] is num) applicants = (json['applicantCount'] as num).toInt();
      else if (json['applicantsCount'] is int) applicants = json['applicantsCount'] as int;
      else if (json['applicantsCount'] is num) applicants = (json['applicantsCount'] as num).toInt();
      else if (json['applicationsCount'] is int) applicants = json['applicationsCount'] as int;
      else if (json['applicationsCount'] is num) applicants = (json['applicationsCount'] as num).toInt();
      
      // Add views/clicks to make it more attractive
      int views = 0;
      if (json['views'] is int) views = json['views'] as int;
      else if (json['views'] is num) views = (json['views'] as num).toInt();
      else if (json['viewCount'] is int) views = json['viewCount'] as int;
      else if (json['viewCount'] is num) views = (json['viewCount'] as num).toInt();
      else if (json['clicks'] is int) views = json['clicks'] as int;
      else if (json['clicks'] is num) views = (json['clicks'] as num).toInt();
      
      // Return sum of applicants + views for more attractive number
      return applicants + views;
    }
    
    // Parse description and strip HTML tags
    String parseDescription() {
      final raw = json['description'] as String? ?? '';
      return _stripHtml(raw);
    }
    
    return JobModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Untitled',
      description: parseDescription(),
      budget: parseBudget(),
      location: json['location'] as String? ?? 'Remote',
      companyName: parseCompanyName(),
      companyLogo: parseCompanyLogo(),
      coverImage: parseCoverImage(),
      employerId: json['employerId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      createdAt: _parseDateTime(json['createdAt']),
      requirements: _parseStringList(json['requirements']),
      tags: _parseStringList(json['tags']),
      jobType: json['jobType'] as String? ?? json['type'] as String?,
      paymentType: json['paymentType'] as String?,
      experienceLevel: json['experienceLevel'] as String?,
      applicantsCount: parseApplicantsCount(),
      isSaved: false,
    );
  }
  
  // Helper to parse DateTime from various formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  // Helper method to safely parse List<String>
  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'payAmount': budget, // Use payAmount for Vue compatibility
      'location': location,
      'company': companyName, // Use company for Vue compatibility
      'companyLogo': companyLogo,
      'jobPhoto': coverImage, // Vue compatibility (uses jobPhoto)
      'employerId': employerId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'requirements': requirements,
      'tags': tags,
      'jobType': jobType,
      'paymentType': paymentType,
      'experienceLevel': experienceLevel,
      'applicantCount': applicantsCount, // Vue compatibility (singular)
    };
  }

  JobModel copyWith({
    String? id,
    String? title,
    String? description,
    double? budget,
    String? location,
    String? companyName,
    String? companyLogo,
    String? coverImage,
    String? employerId,
    String? status,
    DateTime? createdAt,
    List<String>? requirements,
    List<String>? tags,
    String? jobType,
    String? paymentType,
    String? experienceLevel,
    int? applicantsCount,
    bool? isSaved,
  }) {
    return JobModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      location: location ?? this.location,
      companyName: companyName ?? this.companyName,
      companyLogo: companyLogo ?? this.companyLogo,
      coverImage: coverImage ?? this.coverImage,
      employerId: employerId ?? this.employerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      requirements: requirements ?? this.requirements,
      tags: tags ?? this.tags,
      jobType: jobType ?? this.jobType,
      paymentType: paymentType ?? this.paymentType,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      applicantsCount: applicantsCount ?? this.applicantsCount,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  
  /// Get the best available image for this job
  String? get displayImage => coverImage ?? companyLogo;
}

