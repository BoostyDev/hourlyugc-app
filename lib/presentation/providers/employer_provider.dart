import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Employer data model
class EmployerData {
  final String id;
  final String? companyName;
  final String? industry;
  final String? companySize;
  final String? website;
  final String? companyDescription;
  final String? companyLogo;
  final String? location;
  final String? founded;

  EmployerData({
    required this.id,
    this.companyName,
    this.industry,
    this.companySize,
    this.website,
    this.companyDescription,
    this.companyLogo,
    this.location,
    this.founded,
  });

  factory EmployerData.fromJson(Map<String, dynamic> json, String id) {
    // Get company name (check multiple fields like Vue)
    final companyName = json['companyName'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['name'] as String? : null) ??
        json['businessName'] as String?;

    // Get industry (check multiple fields)
    final industry = json['industry'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['industry'] as String? : null) ??
        json['businessType'] as String?;

    // Get company size
    final companySize = json['companySize'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['size'] as String? : null);

    // Get website
    final website = json['website'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['website'] as String? : null);

    // Get company description
    final companyDescription = json['companyDescription'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['description'] as String? : null) ??
        json['businessDescription'] as String?;

    // Get company logo (check multiple fields)
    final companyLogo = json['companyLogo'] as String? ??
        (json['company'] is Map ? (json['company'] as Map)['logo'] as String? : null) ??
        json['logo'] as String? ??
        json['photoURL'] as String? ??
        json['photoUrl'] as String?;

    // Get location
    final location = json['location'] is String
        ? json['location'] as String
        : (json['location'] is Map
            ? (json['location'] as Map)['city'] as String? ??
                (json['location'] as Map)['address'] as String?
            : null) ??
            json['city'] as String?;

    return EmployerData(
      id: id,
      companyName: companyName,
      industry: industry,
      companySize: companySize,
      website: website,
      companyDescription: companyDescription,
      companyLogo: companyLogo,
      location: location,
      founded: _extractFoundedYear(json),
    );
  }

  /// Extract founded year from createdAt or founded field
  static String? _extractFoundedYear(Map<String, dynamic> json) {
    // First check if there's a founded field
    if (json['founded'] != null) {
      final founded = json['founded'];
      if (founded is String) return founded;
      if (founded is int) return founded.toString();
    }
    
    // Otherwise, try to extract year from createdAt
    if (json['createdAt'] != null) {
      try {
        final createdAt = json['createdAt'];
        if (createdAt is Timestamp) {
          return createdAt.toDate().year.toString();
        }
        if (createdAt is String) {
          final date = DateTime.parse(createdAt);
          return date.year.toString();
        }
      } catch (e) {
        // If parsing fails, return null
        return null;
      }
    }
    
    return null;
  }
}

/// Provider to get employer data by ID
final employerProvider = StreamProvider.family<EmployerData?, String>((ref, employerId) {
  if (employerId.isEmpty) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(employerId)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        return EmployerData.fromJson(doc.data()!, doc.id);
      });
});

