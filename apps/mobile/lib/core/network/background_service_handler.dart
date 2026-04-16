import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter/foundation.dart';

// The callback function for the foreground task.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    debugPrint('Privora: Background Service Started');
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Keep alive logic can go here (e.g. pinging the socket if needed)
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTaskHandlerDestroyed) async {
    debugPrint('Privora: Background Service Destroyed');
  }
}

class BackgroundServiceHandler {
  static Future<void> init() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'privora_background',
        channelName: 'Privora Secure Connection',
        channelDescription: 'Maintains secure end-to-end encrypted connection.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  static Future<bool> start() async {
    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      notificationTitle: 'Privora 1-Tap',
      notificationText: 'Secure tunnel active',
      callback: startCallback,
    );

    return result is ServiceRequestSuccess;
  }

  static Future<bool> stop() async {
    final result = await FlutterForegroundTask.stopService();
    return result is ServiceRequestSuccess;
  }
}
