import 'package:notification_with_pool/src/notification_content.dart';

import 'notification_with_pool_platform_interface.dart';

export 'src/notification_event_controller.dart';
export 'src/notification_event_type.dart';
export 'src/notification_content.dart';

class NotificationWithPool {
  static Future<void> initialize({
    List<NotificationContent>? contentPool,
  }) async {
    return await NotificationWithPoolPlatform.instance.initialize(
      contentPool: contentPool,
    );
  }

  static Future<void> createDailyNotificationWithContentPool({
    required String identifier,
    required int hour,
    required int minute,
    int second = 0,
  }) async {
    return await NotificationWithPoolPlatform.instance.createDailyNotificationWithContentPool(
      identifier: identifier,
      hour: hour,
      minute: minute,
      second: second,
    );
  }

  static Future<void> createNotificationWithContentPool({
    required String identifier,
  }) async {
    return await NotificationWithPoolPlatform.instance.createNotificationWithContentPool(
      identifier: identifier,
    );
  }

  static Future<void> createDelayedNotificationWithContentPool({
    required String identifier,
    required Duration delay,
  }) async {
    return await NotificationWithPoolPlatform.instance.createDelayedNotificationWithContentPool(
      identifier: identifier,
      delay: delay,
    );
  }

  static Future<void> updateContentPool({
    required List<NotificationContent> contentPool,
  }) async {
    return await NotificationWithPoolPlatform.instance.updateContentPool(
      contentPool: contentPool,
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
