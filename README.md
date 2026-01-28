# notification_with_pool

A Flutter plugin for managing local notifications with content pool support. This plugin allows you to create, schedule, and manage notifications efficiently using a content pool approach, where you can define a collection of notification content and randomly select from it.

## Features

- **Content Pool Management**: Initialize and update a pool of notification content that can be randomly selected
- **Immediate Notifications**: Create notifications instantly from the pool or with custom content
- **Scheduled Notifications**: Schedule notifications to be delivered at specific times with custom intervals
- **Flexible Content**: Support for title, body, and optional image in notifications
- **Event Tracking**: Monitor notification lifecycle events (scheduled, delivered, opened)
- **Easy Management**: Update, cancel individual notifications or cancel all at once

## Platform Support

| Platform | Status |
|----------|--------|
| iOS      | ✅     |
| Android  | 🚧 Coming soon |

## Installation

Add this to your package's `pubspec.yaml` file:

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

## iOS Setup

No special configuration needed in `Info.plist`. Just make sure to request notification permissions in your app before using the plugin (see Usage section below).

## Usage

### Basic Setup

First, initialize the plugin with a content pool:

```dart
import 'package:notification_with_pool/notification_with_pool.dart';

// Initialize with a content pool
await NotificationWithPool.initilize(
  contentPool: [
    const NotificationContent(
      title: 'Daily Tip',
      body: 'Remember to stay hydrated!',
    ),
    const NotificationContent(
      title: 'Motivation',
      body: 'You\'re doing great! Keep it up!',
    ),
    const NotificationContent(
      title: 'Reminder',
      body: 'Take a break and stretch!',
    ),
  ],
);
```

### Creating Notifications

#### From Content Pool

Create an immediate notification with random content from the pool:

```dart
await NotificationWithPool.createNotificationWithContentPool(
  identifier: 'my_notification_1',
);
```

#### With Custom Content

Create a notification with specific content:

```dart
await NotificationWithPool.createNotification(
  identifier: 'custom_notification',
  content: const NotificationContent(
    title: 'Custom Title',
    body: 'Custom notification message',
    image: 'path/to/image.png', // Optional
  ),
);
```

### Scheduled Notifications

#### Scheduled from Pool

Schedule a notification that picks random content from the pool:

```dart
await NotificationWithPool.createScheduledNotificationWithContentPool(
  identifier: 'daily_reminder',
  scheduledTime: DateTime.now().add(const Duration(hours: 1)),
  interval: const Duration(days: 1),
);
```

#### Scheduled with Custom Content

Schedule a notification with specific content:

```dart
await NotificationWithPool.createScheduledNotification(
  identifier: 'meeting_reminder',
  content: const NotificationContent(
    title: 'Meeting Reminder',
    body: 'Team meeting starts in 10 minutes',
  ),
  scheduledTime: DateTime.now().add(const Duration(minutes: 10)),
  interval: const Duration(hours: 1),
);
```

### Managing Content Pool

Update the content pool at any time:

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

### Updating Scheduled Notifications

Update the schedule of an existing notification:

```dart
await NotificationWithPool.updateScheduled(
  identifier: 'daily_reminder',
  scheduledTime: DateTime.now().add(const Duration(hours: 2)),
  interval: const Duration(days: 2),
);
```

### Canceling Notifications

Cancel a specific notification:

```dart
await NotificationWithPool.cancel(
  identifier: 'daily_reminder',
);
```

Cancel all notifications:

```dart
await NotificationWithPool.cancelAll();
```

### Listening to Notification Events

Create a custom controller to handle notification events:

```dart
class MyNotificationController extends NotificationEventController {
  @override
  void scheduled(String identifier) {
    print('Notification scheduled: $identifier');
  }

  @override
  void delivered(String identifier) {
    print('Notification delivered: $identifier');
  }

  @override
  void opened(String identifier) {
    print('Notification opened: $identifier');
  }
}

// Initialize the controller
final controller = MyNotificationController();
```

## API Reference

### NotificationWithPool

| Method | Parameters | Description |
|--------|------------|-------------|
| `initilize` | `List<NotificationContent>? contentPool` | Initialize the plugin with optional content pool |
| `createNotificationWithContentPool` | `String identifier` | Create immediate notification from pool |
| `createNotification` | `String identifier, NotificationContent content` | Create notification with custom content |
| `createScheduledNotificationWithContentPool` | `String identifier, DateTime scheduledTime, Duration interval` | Schedule notification from pool |
| `createScheduledNotification` | `String identifier, NotificationContent content, DateTime scheduledTime, Duration interval` | Schedule notification with custom content |
| `updateContentPool` | `List<NotificationContent> contentPool` | Update the content pool |
| `updateScheduled` | `String identifier, DateTime scheduledTime, Duration interval` | Update scheduled notification timing |
| `cancel` | `String identifier` | Cancel specific notification |
| `cancelAll` | - | Cancel all notifications |

### NotificationContent

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `title` | `String` | Yes | Notification title |
| `body` | `String` | Yes | Notification message body |
| `image` | `String?` | No | Optional image path |

### NotificationEventController

Override these methods to handle events:

- `scheduled(String identifier)`: Called when notification is scheduled
- `delivered(String identifier)`: Called when notification is delivered
- `opened(String identifier)`: Called when user opens the notification

## Example

Check out the [example](example/) directory for a complete sample app demonstrating all features.

To run the example:

```bash
cd example
flutter run
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, feature requests, or questions, please file an issue on the [GitHub repository](https://github.com/maojiu-bb/notification_with_pool/issues).

# notification_with_pool
