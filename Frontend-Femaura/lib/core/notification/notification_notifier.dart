import 'package:femaura/core/notification/notification_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNotifier extends StateNotifier<void> {
  NotificationNotifier() : super(null);

  void showNotification(String title, String message) {
    NotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: message,
    );
  }

  void scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) {
    NotificationService.scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: scheduledTime,
    );
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, void>((
  ref,
) {
  return NotificationNotifier();
});
