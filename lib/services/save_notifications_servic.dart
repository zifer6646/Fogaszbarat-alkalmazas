import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dental_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FirestoreNotificationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Center(child: Text('User not logged in'));
    }

    final now = DateTime.now();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('Nem található értesítés.'));
        }

        final notifications = snapshot.data!.docs;

        final futureNotifications = notifications.where((notification) {
          final scheduledTime =
              (notification['scheduledTime'] as Timestamp).toDate();
          return scheduledTime.isAfter(now);
        }).toList();

        if (futureNotifications.isEmpty) {
          return Center(child: Text('Nem találhatók jövőbeli értesítések.'));
        }

        futureNotifications.sort((a, b) {
          final dateA = (a['scheduledTime'] as Timestamp).toDate();
          final dateB = (b['scheduledTime'] as Timestamp).toDate();
          return dateA.compareTo(dateB);
        });

        return ListView.builder(
          itemCount: futureNotifications.length,
          itemBuilder: (context, index) {
            final notification = futureNotifications[index];
            final body = notification['body'];
            final scheduledTime =
                (notification['scheduledTime'] as Timestamp).toDate();

            return ListTile(
              title: Text(body),
              subtitle: Text(
                  'Időpont: ${DateFormat('yyyy-MM-dd HH:mm').format(scheduledTime)}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  final notificationId = notification.id;
                  final localNotificationId = notification['localId'];
                  await NotificationService()
                      .deleteNotification(notificationId, userId);
                  await NotificationService()
                      .cancelNotification(localNotificationId);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Értesítés törölve.')),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
