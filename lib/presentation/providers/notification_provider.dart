import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/notification_model.dart';
import 'auth_provider.dart';

/// Notifications stream provider - listens to important events
final notificationsProvider = StreamProvider<List<NotificationModel>>((ref) {
  final userId = ref.watch(currentUserProvider).value?.uid;
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;
  
  // Listen to applications where user is applicant (for status changes)
  final applicationsStream = firestore
      .collection('applications')
      .where('applicantId', isEqualTo: userId)
      .orderBy('appliedAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docChanges
        .where((change) => change.type == DocumentChangeType.added || 
                          change.type == DocumentChangeType.modified)
        .map((change) {
          final data = change.doc.data()!;
          final status = data['status'] as String? ?? 'pending';
          
          // Only notify on status changes (not new applications - those are shown when created)
          if (change.type == DocumentChangeType.modified) {
            return NotificationModel(
              id: 'app_${change.doc.id}',
              type: 'application_status',
              title: 'Application Status Updated',
              message: 'Your application for "${data['jobTitle'] ?? 'a job'}" is now $status',
              createdAt: DateTime.now(),
              userId: userId,
              data: {'applicationId': change.doc.id, 'status': status},
            );
          }
          return null;
        })
        .where((n) => n != null)
        .cast<NotificationModel>()
        .toList();
  });

  // Listen to contracts where user is creator (for proposals)
  final contractsStream = firestore
      .collection('contracts')
      .where('genzId', isEqualTo: userId)
      .where('status', isEqualTo: 'proposed')
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) {
    return snapshot.docChanges
        .where((change) => change.type == DocumentChangeType.added)
        .map((change) {
          final data = change.doc.data() ?? {};
          return NotificationModel(
            id: 'contract_${change.doc.id}',
            type: 'contract_proposal',
            title: 'New Contract Proposal',
            message: 'You have received a contract proposal for "${data['title'] ?? 'a project'}"',
            createdAt: DateTime.now(),
            userId: userId,
            data: {'contractId': change.doc.id},
          );
        })
        .toList();
  });

  // Combine both streams using asyncExpand
  return applicationsStream.asyncExpand((appNotifications) {
    return contractsStream.map((contractNotifications) {
      final allNotifications = <NotificationModel>[];
      allNotifications.addAll(appNotifications);
      allNotifications.addAll(contractNotifications);
      // Sort by creation date
      allNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allNotifications;
    });
  }).handleError((error) {
    // Return empty list on error
    return <NotificationModel>[];
  });
});

/// Unread notifications count
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

