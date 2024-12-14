import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveNotificationToFirestore({
    required String body,
    required DateTime scheduledTime,
    required String userId,
  }) async {
    try {
      final notificationId = _firestore.collection('notifications').doc().id;
      final localNotificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _firestore.collection('notifications').doc(notificationId).set({
        'id': notificationId,
        'localId': localNotificationId,
        'body': body,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'userId': userId,
      });
      print('Notification saved to Firestore');
    } catch (e) {
      print('Error saving notification to Firestore: $e');
    }
  }

  Future<void> deleteNotification(String notificationId, String userId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      print('Notification deleted from Firestore');
    } catch (e) {
      print('Error deleting notification from Firestore: $e');
    }
  }

  Future<void> cancelNotification(int notificationId) async {
    await FlutterLocalNotificationsPlugin().cancel(notificationId);
  }

  Future<void> initNotification() async {
    await requestExactAlarmPermission();

    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  Future<void> requestExactAlarmPermission() async {
    if (await Permission.notification.isGranted) {
      print("Notification permission already granted.");
    } else {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        print("Notification permission granted.");
      } else {
        print("Notification permission denied.");
      }
    }

    if (await Permission.notification.isGranted &&
        await Permission.notification.request().isGranted) {
      try {
        await Permission.phone.request();
      } on PlatformException catch (e) {
        print("Platform exception while requesting exact alarm permission: $e");
      }
    }
  }

  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        importance: Importance.max,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payLoad,
  }) async {
    return notificationsPlugin.show(
      id,
      title,
      body,
      await notificationDetails(),
    );
  }

  Future<void> scheduleNotification({
    required int id,
    String? title,
    String? body,
    String? payLoad,
    required DateTime scheduledNotificationDateTime,
  }) async {
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledNotificationDateTime,
        tz.local,
      ),
      await notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
