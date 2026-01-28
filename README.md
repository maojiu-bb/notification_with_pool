# notification_with_pool

A Flutter plugin for managing **local notifications** with **content pool** support. Define a pool of notification content (title, body, optional image), and the plugin randomly picks one each time you create or schedule a notification—ideal for daily tips, reminders, or varied messaging without hardcoding each notification.

## Overview

- **Content pool**: Initialize with a list of `NotificationContent`; each scheduled notification randomly selects one item from the pool.
- **Notification types**: Immediate, delayed (one-time), and daily repeating.
- **Events**: Subscribe to `scheduled`, `delivered`, and `opened` via `NotificationEventController`.
- **Persistence**: Daily schedules are stored and restored on app restart (iOS).
- **Images**: Optional image URL per content item; the plugin downloads and attaches it to the notification (iOS).

## Features

- **Content pool management**: Initialize and update a pool of notification content; each notification uses a random item from the pool.
- **Immediate notifications**: Create notifications that fire shortly after scheduling (e.g. ~1 second).
- **Daily notifications**: Schedule repeating daily notifications at a fixed time; content is randomized each day and schedules are persisted.
- **Delayed notifications**: One-time notifications that fire after a specified duration.
- **Rich content**: Title, body, and optional image URL (downloaded and attached on iOS).
- **Event tracking**: Listen for `scheduled`, `delivered`, and `opened` events.
- **Management**: Update the content pool, cancel a single notification by identifier, or cancel all.

## Platform support

| Platform | Status |
|----------|--------|
| iOS      | ✅     |
| Android  | 🚧 Coming soon |

## Prerequisites

- Flutter SDK `^3.5.3`, Flutter `>=3.3.0`.
- **iOS**: Notification permission is requested by the plugin during `initialize`. Ensure your app does not block or override the system permission prompt if you want users to allow notifications.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  notification_with_pool:
    git:
      url: https://github.com/maojiu-bb/notification_with_pool.git
```

Then run:

```bash
flutter pub get
```

## iOS setup

No extra `Info.plist` configuration is required. The plugin requests notification permission when you call `initialize`. You may add usage descriptions (e.g. for other features); for local notifications, the system dialog is sufficient.

## Usage

### 1. Initialize with a content pool

Call `initialize` once (e.g. at app startup), with an optional content pool. Permission is requested here if needed.

```dart
import 'package:notification_with_pool/notification_with_pool.dart';

await NotificationWithPool.initialize(
  contentPool: [
    const NotificationContent(
      title: 'Daily Tip',
      body: 'Remember to stay hydrated!',
    ),
    const NotificationContent(
      title: 'Motivation',
      body: "You're doing great! Keep it up!",
    ),
    const NotificationContent(
      title: 'Reminder',
      body: 'Take a break and stretch!',
      image: 'https://example.com/image.png', // optional; iOS downloads and attaches
    ),
  ],
);
```

### 2. Create notifications

**Immediate** (fires shortly after scheduling):

```dart
await NotificationWithPool.createNotificationWithContentPool(
  identifier: 'my_notification_1',
);
```

**Daily repeating** (fires every day at the given time; content randomized each day):

```dart
await NotificationWithPool.createDailyNotificationWithContentPool(
  identifier: 'daily_reminder',
  hour: 9,
  minute: 0,
  second: 0,
);
```

**Delayed one-time** (fires once after the given duration):

```dart
await NotificationWithPool.createDelayedNotificationWithContentPool(
  identifier: 'delayed_reminder',
  delay: const Duration(minutes: 10),
);
```

### 3. Manage content pool

Update the pool at any time. Future scheduled notifications will use the new pool.

```dart
await NotificationWithPool.updateContentPool(
  contentPool: [
    const NotificationContent(
      title: 'New Content',
      body: 'Updated pool content',
    ),
  ],
);
```

### 4. Cancel notifications

```dart
// Cancel one
await NotificationWithPool.cancel(identifier: 'daily_reminder');

// Cancel all
await NotificationWithPool.cancelAll();
```

### 5. Listen to notification events

Implement a subclass of `NotificationEventController` and **instantiate it** (e.g. in `initState`) so it registers with the event stream. Then override `scheduled`, `delivered`, and `opened` as needed.

```dart
class MyNotificationController extends NotificationEventController {
  final void Function(String message) onEvent;

  MyNotificationController({required this.onEvent});

  @override
  void scheduled(String identifier) {
    onEvent('Scheduled: $identifier');
  }

  @override
  void delivered(String identifier) {
    onEvent('Delivered: $identifier');
  }

  @override
  void opened(String identifier) {
    onEvent('Opened: $identifier');
  }
}

// In your widget (e.g. State.initState):
void initState() {
  super.initState();
  MyNotificationController(
    onEvent: (message) {
      setState(() => _eventLog.insert(0, message));
    },
  );
  // ... then call NotificationWithPool.initialize(...), etc.
}
```

- **scheduled**: Fired when the notification is successfully scheduled with the system.
- **delivered**: Fired when the notification is shown to the user (e.g. banner).
- **opened**: Fired when the user taps the notification (e.g. opens the app).

## API reference

### NotificationWithPool

| Method | Parameters | Description |
|--------|-------------|-------------|
| `initialize` | `List<NotificationContent>? contentPool` | Initialize the plugin and optionally set the content pool. Requests permission if needed. |
| `createNotificationWithContentPool` | `String identifier` | Create an immediate notification with random content from the pool. |
| `createDailyNotificationWithContentPool` | `String identifier`, `int hour`, `int minute`, `int second` (default `0`) | Create a daily repeating notification at the given time. |
| `createDelayedNotificationWithContentPool` | `String identifier`, `Duration delay` | Create a one-time notification that fires after `delay`. |
| `updateContentPool` | `List<NotificationContent> contentPool` | Replace the content pool. |
| `cancel` | `String identifier` | Cancel the notification with the given identifier. |
| `cancelAll` | — | Cancel all notifications created by this plugin. |

### NotificationContent

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | `String` | Yes | Notification title. |
| `body` | `String` | Yes | Notification body text. |
| `image` | `String?` | No | Optional image URL; on iOS the image is downloaded and attached to the notification. |

### NotificationEventController

Subclass and override to handle events. **You must instantiate the controller** (e.g. in `initState`) for it to receive events.

| Callback | Description |
|----------|-------------|
| `scheduled(String identifier)` | Notification was scheduled. |
| `delivered(String identifier)` | Notification was delivered (shown). |
| `opened(String identifier)` | User opened the notification. |

## Example app

The [example](example/) app demonstrates initialization, all notification types, pool updates, cancel operations, and event logging.

Run it:

```bash
cd example
flutter run
```

## How events flow

1. **Initialize**: Plugin requests notification permission (if needed) and restores persisted daily schedules (iOS).
2. **Schedule**: A random item is chosen from the content pool; if it has an image URL, it is downloaded (iOS) and attached; the notification is scheduled with the system; `scheduled` is emitted.
3. **Delivery**: When the system shows the notification, the plugin emits `delivered` (e.g. badge may be updated).
4. **Open**: When the user taps the notification, the plugin emits `opened` (e.g. badge cleared, daily notifications may be rescheduled with new random content).

## Contributing

Contributions are welcome. Please open an issue or submit a pull request on the [GitHub repository](https://github.com/maojiu-bb/notification_with_pool).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Support

For bugs, feature requests, or questions, please [open an issue](https://github.com/maojiu-bb/notification_with_pool/issues) on GitHub.
