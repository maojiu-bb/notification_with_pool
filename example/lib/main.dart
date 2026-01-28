import 'package:flutter/material.dart';
import 'package:notification_with_pool/notification_with_pool.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Pool Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    // Initialize notification controller to listen for events
    MyNotificationController(
      onEvent: (message) {
        setState(() {
          _eventLog.insert(0, message);
        });
      },
    );
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    // Initialize with a content pool
    await NotificationWithPool.initialize(
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
  }

  void _createNotificationFromPool() async {
    await NotificationWithPool.createNotificationWithContentPool(
      identifier: 'pool_notification_${DateTime.now().millisecondsSinceEpoch}',
    );
    _showSnackbar('Notification created from pool');
  }

  void _createDelayedNotificationFromPool() async {
    await NotificationWithPool.createDelayedNotificationWithContentPool(
      identifier: 'delayed_pool_notification',
      delay: const Duration(seconds: 10),
    );
    _showSnackbar('Delayed notification created (will fire in 10 seconds)');
  }

  void _createDailyNotificationFromPool() async {
    final nextMinute = DateTime.now().add(const Duration(minutes: 1));
    await NotificationWithPool.createDailyNotificationWithContentPool(
      identifier: 'daily_pool_notification',
      hour: nextMinute.hour,
      minute: nextMinute.minute,
      second: 0,
    );
    _showSnackbar('Daily notification created');
  }

  void _updateContentPool() async {
    await NotificationWithPool.updateContentPool(
      contentPool: [
        const NotificationContent(
          title: 'Updated Tip',
          body: 'New content pool has been set!',
        ),
        const NotificationContent(
          title: 'Fresh Content',
          body: 'This is from the updated pool',
        ),
      ],
    );
    _showSnackbar('Content pool updated');
  }

  void _cancelNotification() async {
    await NotificationWithPool.cancel(
      identifier: 'delayed_pool_notification',
    );
    _showSnackbar('Delayed pool notification canceled');
  }

  void _cancelAllNotifications() async {
    await NotificationWithPool.cancelAll();
    _showSnackbar('All notifications canceled');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Notification Pool Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Notification Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _createNotificationFromPool,
              icon: const Icon(Icons.notifications),
              label: const Text('Create from Pool'),
            ),
            ElevatedButton.icon(
              onPressed: _createDelayedNotificationFromPool,
              icon: const Icon(Icons.timer),
              label: const Text('Delayed from Pool (10s)'),
            ),
            ElevatedButton.icon(
              onPressed: _createDailyNotificationFromPool,
              icon: const Icon(Icons.schedule),
              label: const Text('Daily from Pool'),
            ),
            const Divider(height: 32),
            const Text(
              'Management',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _updateContentPool,
              icon: const Icon(Icons.update),
              label: const Text('Update Content Pool'),
            ),
            ElevatedButton.icon(
              onPressed: _cancelNotification,
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Scheduled Pool'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            ElevatedButton.icon(
              onPressed: _cancelAllNotifications,
              icon: const Icon(Icons.clear_all),
              label: const Text('Cancel All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const Divider(height: 32),
            const Text(
              'Event Log',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _eventLog.isEmpty
                    ? const Center(
                        child: Text(
                          'No events yet...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _eventLog.length,
                        itemBuilder: (context, index) {
                          return Text(_eventLog[index]);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom notification controller to handle events
class MyNotificationController extends NotificationEventController {
  final Function(String) onEvent;

  MyNotificationController({required this.onEvent});

  @override
  void scheduled(String identifier) {
    final message = '[${DateTime.now().toString().substring(11, 19)}] Scheduled: $identifier';
    debugPrint(message);
    onEvent(message);
  }

  @override
  void delivered(String identifier) {
    final message = '[${DateTime.now().toString().substring(11, 19)}] Delivered: $identifier';
    debugPrint(message);
    onEvent(message);
  }

  @override
  void opened(String identifier) {
    final message = '[${DateTime.now().toString().substring(11, 19)}] Opened: $identifier';
    debugPrint(message);
    onEvent(message);
  }
}
