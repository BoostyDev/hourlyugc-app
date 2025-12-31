import 'package:cloud_firestore/cloud_firestore.dart';

/// User model for Creators (genz)
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String userType; // 'genz'
  final String? phoneNumber;
  final String? profileImage;
  final bool registrationCompleted;
  final DateTime createdAt;
  final Portfolio? portfolio;
  final SocialMedia? socialMedia;
  final String? university;
  final String? bio;
  final List<String>? skills;
  final double balance; // Total available balance
  final double pendingBalance; // Pending earnings

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.phoneNumber,
    this.profileImage,
    required this.registrationCompleted,
    required this.createdAt,
    this.portfolio,
    this.socialMedia,
    this.university,
    this.bio,
    this.skills,
    this.balance = 0.0,
    this.pendingBalance = 0.0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse balance - handle both direct value and nested balance object
    double parseBalance(Map<String, dynamic> json) {
      if (json['balance'] is num) {
        return (json['balance'] as num).toDouble();
      }
      if (json['balance'] is Map) {
        final balanceMap = json['balance'] as Map<String, dynamic>;
        return ((balanceMap['available'] as num?) ?? 0).toDouble() +
               ((balanceMap['pending'] as num?) ?? 0).toDouble();
      }
      return 0.0;
    }
    
    double parsePendingBalance(Map<String, dynamic> json) {
      if (json['pendingBalance'] is num) {
        return (json['pendingBalance'] as num).toDouble();
      }
      if (json['balance'] is Map) {
        final balanceMap = json['balance'] as Map<String, dynamic>;
        return ((balanceMap['pending'] as num?) ?? 0).toDouble();
      }
      return 0.0;
    }
    
    return UserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      userType: json['userType'] as String? ?? 'genz',
      phoneNumber: json['phoneNumber'] as String?,
      profileImage: json['profileImage'] as String?,
      registrationCompleted: json['registrationCompleted'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      portfolio: json['portfolio'] != null
          ? Portfolio.fromJson(json['portfolio'] as Map<String, dynamic>)
          : null,
      socialMedia: json['socialMedia'] != null
          ? SocialMedia.fromJson(json['socialMedia'] as Map<String, dynamic>)
          : null,
      university: json['university'] as String?,
      bio: json['bio'] as String?,
      skills: _parseStringList(json['skills']),
      balance: parseBalance(json),
      pendingBalance: parsePendingBalance(json),
    );
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
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'userType': userType,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'registrationCompleted': registrationCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'portfolio': portfolio?.toJson(),
      'socialMedia': socialMedia?.toJson(),
      'university': university,
      'bio': bio,
      'skills': skills,
      'balance': {
        'available': balance - pendingBalance,
        'pending': pendingBalance,
      },
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? firstName,
    String? lastName,
    String? userType,
    String? phoneNumber,
    String? profileImage,
    bool? registrationCompleted,
    DateTime? createdAt,
    Portfolio? portfolio,
    SocialMedia? socialMedia,
    String? university,
    String? bio,
    List<String>? skills,
    double? balance,
    double? pendingBalance,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userType: userType ?? this.userType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      registrationCompleted: registrationCompleted ?? this.registrationCompleted,
      createdAt: createdAt ?? this.createdAt,
      portfolio: portfolio ?? this.portfolio,
      socialMedia: socialMedia ?? this.socialMedia,
      university: university ?? this.university,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      balance: balance ?? this.balance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
    );
  }

  String get fullName => '$firstName $lastName';
}

class Portfolio {
  final String slug;
  final bool isPublic;
  final List<dynamic> blocks;

  Portfolio({
    required this.slug,
    required this.isPublic,
    required this.blocks,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      slug: json['slug'] as String,
      isPublic: json['isPublic'] as bool? ?? false,
      blocks: (json['blocks'] is List) ? json['blocks'] as List<dynamic> : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'isPublic': isPublic,
      'blocks': blocks,
    };
  }
}

class SocialMedia {
  final String? instagram;
  final String? tiktok;
  final String? youtube;
  final String? twitter;

  SocialMedia({
    this.instagram,
    this.tiktok,
    this.youtube,
    this.twitter,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      instagram: json['instagram'] as String?,
      tiktok: json['tiktok'] as String?,
      youtube: json['youtube'] as String?,
      twitter: json['twitter'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instagram': instagram,
      'tiktok': tiktok,
      'youtube': youtube,
      'twitter': twitter,
    };
  }
}

