import 'package:notification_with_pool/src/notification_content.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'notification_with_pool_method_channel.dart';

abstract class NotificationWithPoolPlatform extends PlatformInterface {
  /// Constructs a NotificationWithPoolPlatform.
  NotificationWithPoolPlatform() : super(token: _token);

  static final Object _token = Object();

  static NotificationWithPoolPlatform _instance = MethodChannelNotificationWithPool();

  /// The default instance of [NotificationWithPoolPlatform] to use.
  ///
  /// Defaults to [MethodChannelNotificationWithPool].
  static NotificationWithPoolPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NotificationWithPoolPlatform] when
  /// they register themselves.
  static set instance(NotificationWithPoolPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initilize({
    List<NotificationContent>? contentPool,
  }) async {
    throw UnimplementedError('initilize() has not been implemented.');
  }

  Future<void> createScheduledNotificationWithContentPool({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    throw UnimplementedError(
        'createScheduledNotificationWithContentPool() has not been implemented.');
  }

  Future<void> createNotificationWithContentPool({
    required String identifier,
  }) async {
    throw UnimplementedError('createNotificationWithContentPool() has not been implemented.');
  }

  Future<void> createNotification({
    required String identifier,
    required NotificationContent content,
  }) async {
    throw UnimplementedError('createNotification() has not been implemented.');
  }

  Future<void> createScheduledNotification({
    required String identifier,
    required NotificationContent content,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    throw UnimplementedError('createScheduledNotification() has not been implemented.');
  }

  Future<void> updateContentPool({
    required List<NotificationContent> contentPool,
  }) async {
    throw UnimplementedError('updateContentPool() has not been implemented.');
  }

  Future<void> updateScheduled({
    required String identifier,
    required DateTime scheduledTime,
    required Duration interval,
  }) async {
    throw UnimplementedError('updateScheduled() has not been implemented.');
  }

  Future<void> cancel({
    required String identifier,
  }) async {
    throw UnimplementedError('cancel() has not been implemented.');
  }

  Future<void> cancelAll() async {
    throw UnimplementedError('cancelAll() has not been implemented.');
  }
}
