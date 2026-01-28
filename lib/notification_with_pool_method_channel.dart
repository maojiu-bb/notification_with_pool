import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:notification_with_pool/src/method_keys.dart';
import 'package:notification_with_pool/src/notification_content.dart';

import 'notification_with_pool_platform_interface.dart';

/// An implementation of [NotificationWithPoolPlatform] that uses method channels.
class MethodChannelNotificationWithPool extends NotificationWithPoolPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('notification_with_pool');

  @override
  Future<void> initilize({
    List<NotificationContent>? contentPool,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.initilize,
      {'contentPool': contentPool?.map((content) => content.toJson()).toList()},
    );
  }

  @override
  Future<void> createScheduledNotificationWithContentPool({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.createScheduledNotificationWithContentPool,
      {
        'identifier': identifier,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch / 1000.0,
        'interval': interval.inSeconds,
      },
    );
  }

  @override
  Future<void> createNotificationWithContentPool({
    required String identifier,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.createNotificationWithContentPool,
      {
        'identifier': identifier,
      },
    );
  }

  @override
  Future<void> createNotification({
    required NotificationContent content,
    required String identifier,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.createNotification,
      {
        'identifier': identifier,
        'content': content.toJson(),
      },
    );
  }

  @override
  Future<void> createScheduledNotification({
    required String identifier,
    required NotificationContent content,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.createScheduledNotification,
      {
        'identifier': identifier,
        'content': content.toJson(),
        'scheduledTime': scheduledTime.millisecondsSinceEpoch / 1000.0,
        'interval': interval.inSeconds,
      },
    );
  }

  @override
  Future<void> updateContentPool({
    required List<NotificationContent> contentPool,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.updateContentPool,
      {
        'contentPool': contentPool.map((content) => content.toJson()).toList(),
      },
    );
  }

  @override
  Future<void> updateScheduled({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.updateScheduled,
      {
        'identifier': identifier,
        'scheduledTime': scheduledTime.millisecondsSinceEpoch / 1000.0,
        'interval': interval.inSeconds,
      },
    );
  }

  @override
  Future<void> cancel({
    required String identifier,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.cancel,
      {'identifier': identifier},
    );
  }

  @override
  Future<void> cancelAll() async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.cancelAll,
    );
  }
}
