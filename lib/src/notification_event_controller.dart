import 'dart:async';

import 'package:notification_with_pool/src/notification_event_channel.dart';
import 'package:notification_with_pool/src/notification_event_type.dart';

abstract class NotificationEventController {
  NotificationEventController() {
    _NotificationEventHub.instance._register(this);
  }

  void scheduled(String identifier) {}
  void delivered(String identifier) {}
  void opened(String identifier) {}
}

class _NotificationEventHub {
  _NotificationEventHub._() {
    _listen();
  }

  static final _NotificationEventHub instance = _NotificationEventHub._();

  final List<NotificationEventController> _controllers = [];

  StreamSubscription? _subscription;

  void _register(NotificationEventController controller) {
    _controllers.add(controller);
  }

  void _listen() {
    _subscription ??= NotificationEventChannel.events.listen(_dispatch);
  }

  void _dispatch(NotificationEvent event) {
    for (final c in _controllers) {
      switch (event.type) {
        case NotificationEventType.scheduled:
          c.scheduled(event.identifier);
          break;
        case NotificationEventType.delivered:
          c.delivered(event.identifier);
          break;
        case NotificationEventType.opened:
          c.opened(event.identifier);
          break;
      }
    }
  }
}
