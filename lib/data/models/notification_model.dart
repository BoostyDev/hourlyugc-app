import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification model for important messages
class NotificationModel {
  final String id;
  final String type; // 'contract_proposal', 'application_submitted', 'application_status', 'contract_status'
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? userId; // Target user
  final Map<String, dynamic>? data; // Additional data (contractId, applicationId, etc)

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.userId,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
      userId: json['userId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'userId': userId,
      'data': data,
    };
  }
}

