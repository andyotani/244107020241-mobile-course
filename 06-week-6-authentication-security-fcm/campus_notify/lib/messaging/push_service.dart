
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';

// ==========================================
// 1. LOCAL NOTIFICATION PLUGIN
// ==========================================

final FlutterLocalNotificationsPlugin _local =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

// Callback untuk navigasi dari local notification
void Function(String route)? _notificationNavigation;

// ==========================================
// 2. BACKGROUND MESSAGE HANDLER
// WAJIB TOP-LEVEL FUNCTION
// ==========================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message received');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Payload: ${message.data}');
}

// ==========================================
// 3. REGISTER BACKGROUND HANDLER
// ==========================================

void registerBackgroundHandler() {
  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
}

// ==========================================
// 4. REQUEST NOTIFICATION PERMISSION
// ==========================================

Future<bool> requestNotificationPermission() async {
  final settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
    announcement: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
  );

  final authorized =
      settings.authorizationStatus ==
          AuthorizationStatus.authorized ||
      settings.authorizationStatus ==
          AuthorizationStatus.provisional;

  debugPrint(
    'Notification permission: ${settings.authorizationStatus}',
  );

  return authorized;
}

// ==========================================
// 5. INITIALIZE LOCAL NOTIFICATIONS
// ==========================================

Future<void> initLocalNotifications() async {
  const androidSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const iosSettings = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await _local.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      final route = response.payload;

      if (route != null && route.isNotEmpty) {
        if (_notificationNavigation != null) {
          _notificationNavigation!(route);
        } else {
          pendingDeepLink = route;
        }
      }

      debugPrint('Local notification clicked: $route');
    },
  );

  // Notification channel Android
  const channel = AndroidNotificationChannel(
    'campus_notify_channel',
    'Pengumuman Kampus',
    description: 'Notifikasi pengumuman dari kampus',
    importance: Importance.high,
  );

  await _local
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  debugPrint('Local notification initialized');
}

// ==========================================
// 6. SHOW LOCAL NOTIFICATION
// ==========================================

Future<void> showLocalNotification(
  RemoteMessage message,
) async {
  final notification = message.notification;

  final route = message.data['route'] ?? '/';

  await _local.show(
    id: message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch,
    title: notification?.title ?? 'Pengumuman Kampus',
    body: notification?.body ?? 'Ada pengumuman baru.',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        'campus_notify_channel',
        'Pengumuman Kampus',
        channelDescription: 'Notifikasi pengumuman dari kampus',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    payload: route,
  );

  debugPrint('Local notification displayed: $route');
}

// ==========================================
// 7. NAVIGATION HANDLER
// ==========================================

void registerNotificationNavigation(
  void Function(String route) go,
) {
  _notificationNavigation = go;

  // Memproses deep link yang tertunda
  if (pendingDeepLink != null) {
    final route = pendingDeepLink!;
    pendingDeepLink = null;

    go(route);
  }
}

// ==========================================
// 8. LISTEN FOREGROUND + BACKGROUND
// ==========================================

void listenForeground(
  void Function(String route) go,
) {
  // FOREGROUND:
  // Tampilkan local notification secara manual.
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      debugPrint('Foreground message received');
      debugPrint('Payload: ${message.data}');

      await showLocalNotification(message);
    },
  );

  // BACKGROUND:
  // Pengguna mengeklik notifikasi sistem.
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      final route = message.data['route'] ?? '/';

      debugPrint('Background notification clicked: $route');

      go(route);
    },
  );
}

// ==========================================
// 9. HANDLE TERMINATED STATE
// ==========================================

Future<void> handleTerminated(
  void Function(String route) go,
) async {
  // FCM notification yang membuka aplikasi dari kondisi terminated
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    final route = initialMessage.data['route'] ?? '/';

    debugPrint('Terminated notification clicked: $route');

    go(route);
    return;
  }

  // Deep link dari local notification yang tertunda
  if (pendingDeepLink != null) {
    final route = pendingDeepLink!;

    pendingDeepLink = null;

    debugPrint('Pending notification route: $route');

    go(route);
  }
}

// ==========================================
// 10. FCM TOKEN LIFECYCLE
// ==========================================

Future<void> initFcmToken({
  required Future<void> Function(String token) onToken,
}) async {
  // Mengambil token perangkat
  final token = await FirebaseMessaging.instance.getToken();

  if (token != null) {
    await onToken(token);
  }

  // Memantau perubahan token
  FirebaseMessaging.instance.onTokenRefresh.listen(
    (newToken) async {
      debugPrint('FCM Token successfully refreshed');

      await onToken(newToken);
    },
    onError: (error) {
      debugPrint('FCM Token refresh error: $error');
    },
  );

  // Berlangganan topik kampus
  await subscribeCampusTopic();
}

// ==========================================
// 11. TOPIC SUBSCRIBE
// ==========================================

Future<void> subscribeCampusTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic(
    'pengumuman-kampus',
  );

  debugPrint('Subscribed to pengumuman-kampus');
}

// ==========================================
// 12. TOPIC UNSUBSCRIBE
// ==========================================

Future<void> unsubscribeCampusTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(
    'pengumuman-kampus',
  );

  debugPrint('Unsubscribed from pengumuman-kampus');
}
