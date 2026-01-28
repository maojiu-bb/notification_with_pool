enum NotificationEventType {
  scheduled,
  delivered,
  opened,
}

class NotificationEvent {
  final NotificationEventType type;
  final String identifier;

  NotificationEvent(this.type, this.identifier);

  factory NotificationEvent.fromMap(Map map) {
    final typeStr = map['type'] as String?;

    final type = NotificationEventType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NotificationEventType.scheduled,
    );

    return NotificationEvent(type, map['identifier'] ?? '');
  }
}
