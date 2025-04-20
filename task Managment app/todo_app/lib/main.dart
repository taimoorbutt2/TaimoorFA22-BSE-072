import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_app/providers/task_provider.dart';
import 'package:todo_app/screens/home/home.dart';
import 'package:todo_app/services/notification_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // Request notification permissions
  bool? androidPermission = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
  bool? iosPermission = await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);
  debugPrint('Main: Android notification permission: $androidPermission');
  debugPrint('Main: iOS notification permission: $iosPermission');

  bool? initialized = await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      debugPrint('Main: Received notification response with payload: ${response.payload}');
      if (response.payload != null) {
        // Payload format: "categoryId:taskIndex"
        final parts = response.payload!.split(':');
        if (parts.length == 2) {
          debugPrint('Main: Parsed payload - categoryId=${parts[0]}, taskIndex=${parts[1]}');
        }
      }
    },
  );
  debugPrint('Main: Notification initialization successful: $initialized');

  // Check if app was launched from a notification
  final NotificationAppLaunchDetails? notificationLaunchDetails =
  await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? initialPayload = notificationLaunchDetails?.didNotificationLaunchApp == true
      ? notificationLaunchDetails?.notificationResponse?.payload
      : null;
  debugPrint('Main: App launched from notification with payload: $initialPayload');

  runApp(MyApp(initialPayload: initialPayload));
}

class MyApp extends StatelessWidget {
  final String? initialPayload;

  const MyApp({Key? key, this.initialPayload}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TaskProvider()..loadTasks(),
      child: MaterialApp(
        title: 'Task App',
        theme: ThemeData(
          primaryColor: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
          appBarTheme: const AppBarTheme(
            elevation: 4,
            shadowColor: Colors.black26,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: Colors.black26,
            ),
          ),
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(8),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: HomePage(initialNotificationPayload: initialPayload),
      ),
    );
  }
}