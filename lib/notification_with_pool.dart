import 'package:notification_with_pool/src/notification_content.dart';

import 'notification_with_pool_platform_interface.dart';

export 'src/notification_event_controller.dart';
export 'src/notification_event_type.dart';
export 'src/notification_content.dart';

class NotificationWithPool {
  static Future<void> initilize({
    List<NotificationContent>? contentPool,
  }) async {
    return await NotificationWithPoolPlatform.instance.initilize(
      contentPool: contentPool,
    );
  }

  static Future<void> createScheduledNotificationWithContentPool({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await NotificationWithPoolPlatform.instance.createScheduledNotificationWithContentPool(
      identifier: identifier,
      scheduledTime: scheduledTime,
      interval: interval,
    );
  }

  static Future<void> createNotificationWithContentPool({
    required String identifier,
  }) async {
    return await NotificationWithPoolPlatform.instance.createNotificationWithContentPool(
      identifier: identifier,
    );
  }

  static Future<void> createNotification({
    required String identifier,
    required NotificationContent content,
  }) async {
    return await NotificationWithPoolPlatform.instance.createNotification(
      identifier: identifier,
      content: content,
    );
  }

  static Future<void> createScheduledNotification({
    required String identifier,
    required NotificationContent content,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await NotificationWithPoolPlatform.instance.createScheduledNotification(
      identifier: identifier,
      content: content,
      scheduledTime: scheduledTime,
      interval: interval,
    );
  }

  static Future<void> updateContentPool({
    required List<NotificationContent> contentPool,
  }) async {
    return await NotificationWithPoolPlatform.instance.updateContentPool(
      contentPool: contentPool,
    );
  }

  static Future<void> updateScheduled({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await NotificationWithPoolPlatform.instance.updateScheduled(
      identifier: identifier,
      scheduledTime: scheduledTime,
      interval: interval,
    );
  }

  static Future<void> cancel({
    required String identifier,
  }) async {
    return await NotificationWithPoolPlatform.instance.cancel(
      identifier: identifier,
    );
  }

  static Future<void> cancelAll() async {
    return await NotificationWithPoolPlatform.instance.cancelAll();
  }
}
