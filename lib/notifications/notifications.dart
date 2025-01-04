import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationsApi {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future init() async {
    const android = AndroidInitializationSettings("ic_notification");
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings, onDidReceiveNotificationResponse : (_) {});
  }

  static void showNotification({
    String? title,
    String? body,
  }) async {
    _notifications.show(
        1,
        title,
        body,
        const NotificationDetails(
            android: AndroidNotificationDetails("channel", "name",
                importance: Importance.max)));
  }

  static void sendDrinkReminder() {
    NotificationsApi.showNotification(
        body: "Time to drink something!", title: "hydra8 Yourself");
  }
}


void remindersCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    await NotificationsApi.init();
    if (TimeOfDay.now().toString() == inputData?["init_time"]) {
      return Future.value(true);
    }
    if (TimeOfDay.now().hour > inputData?["start_hour"] && // 9:00  now: 9:30
        TimeOfDay.now().hour < inputData?["finish_hour"]) {
      if (TimeOfDay.now().hour == inputData?["start_hour"]) {
        if (TimeOfDay.now().minute > inputData?["start_minute"]) {
          NotificationsApi.sendDrinkReminder();
        }
      } else if (TimeOfDay.now().hour == inputData?["finish_hour"]) {
        if (TimeOfDay.now().minute < inputData?["finish_minute"]) {
          NotificationsApi.sendDrinkReminder();
        }
      } else {
        NotificationsApi.sendDrinkReminder();
      }
    }
    return Future.value(true);
  });
}
