import 'dart:async';
import 'package:flutter/services.dart';
import 'package:notification_with_pool/src/notification_event_type.dart';

class NotificationEventChannel {
  static const _channel = EventChannel('notification_with_pool/events');

  static Stream<NotificationEvent>? _stream;

  static Stream<NotificationEvent> get events {
    _stream ??= _channel.receiveBroadcastStream().map((event) => NotificationEvent.fromMap(event));
    return _stream!;
  }
}
