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
  Future<void> initialize({
    List<NotificationContent>? contentPool,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.INITIALIZE,
      {'contentPool': contentPool?.map((content) => content.toJson()).toList()},
    );
  }

  @override
  Future<void> createDailyNotificationWithContentPool({
    required String identifier,
    required int hour,
    required int minute,
    int second = 0,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.CREATE_DAILY_NOTIFICATION_WITH_CONTENT_POOL,
      {
        'identifier': identifier,
        'hour': hour,
        'minute': minute,
        'second': second,
      },
    );
  }

  @override
  Future<void> createNotificationWithContentPool({
    required String identifier,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.CREATE_NOTIFICATION_WITH_CONTENT_POOL,
      {
        'identifier': identifier,
      },
    );
  }

  @override
  Future<void> createDelayedNotificationWithContentPool({
    required String identifier,
    required Duration delay,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.CREATE_DELAYED_NOTIFICATION_WITH_CONTENT_POOL,
      {
        'identifier': identifier,
        'delay': delay.inSeconds,
      },
    );
  }

  @override
  Future<void> updateContentPool({
    required List<NotificationContent> contentPool,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.UPDATE_CONTENT_POOL,
      {
        'contentPool': contentPool.map((content) => content.toJson()).toList(),
      },
    );
  }

  @override
  Future<void> cancel({
    required String identifier,
  }) async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.CANCEL,
      {'identifier': identifier},
    );
  }

  @override
  Future<void> cancelAll() async {
    return await methodChannel.invokeMethod<void>(
      MethodKeys.CANCEL_ALL,
    );
  }
}
