
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import '../data/notification_store.dart';

// ==========================================
// LOCAL NOTIFICATION
// ==========================================

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

String? pendingDeepLink;

void Function(String? route)? _onNotificationTap;

// ==========================================
// NOTIFICATION CHANNEL (SUARA + POP-UP)
// ==========================================

const String notificationSoundName = 'campus_notification';
const String notificationChannelId = 'campus_notif_chime_v1';

const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
  notificationChannelId,
  'Campus Notif Sound',
  description: 'Notifikasi kampus dengan suara dan getaran',
  importance: Importance.high,
  playSound: true,
  sound: RawResourceAndroidNotificationSound(notificationSoundName),
  enableVibration: true,
);

// ==========================================
// 1. BACKGROUND MESSAGE HANDLER
// ==========================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  DartPluginRegistrant.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint(
    'Background message: ${message.messageId}',
  );

  final notification = message.notification;

  if (notification != null) {
    final id = message.messageId ??
        '${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';

    await NotificationStore().add(
      id: id,
      title: notification.title ?? 'Campus Notif',
      body: notification.body ?? '',
      route: message.data['route']?.toString(),
    );
  }
}

// ==========================================
// 2. REQUEST PERMISSION
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
// 3. INITIALIZE LOCAL NOTIFICATION
// ==========================================

Future<void> initLocalNotifications({
  required void Function(String? route) onTap,
}) async {
  _onNotificationTap = onTap;

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const iosSettings = DarwinInitializationSettings();

  const initializationSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await localNotifications.initialize(
    settings: initializationSettings,
    onDidReceiveNotificationResponse: (response) {
      pendingDeepLink = response.payload;

      _onNotificationTap?.call(response.payload);

      debugPrint('Local notification clicked');
    },
  );

  // Channel baru dengan suara dan getaran.
  await localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(notificationChannel);

  debugPrint('Local notification initialized');
}

// ==========================================
// 4. SHOW LOCAL NOTIFICATION
// ==========================================

Future<void> showLocalNotification(
  RemoteMessage message,
) async {
  final notification = message.notification;

  if (notification == null) return;

  await localNotifications.show(
    id: (message.messageId?.hashCode ??
            DateTime.now().millisecondsSinceEpoch) &
        0x7fffffff,
    title: notification.title ?? 'Campus Notif',
    body: notification.body ?? '',
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        notificationChannelId,
        'Campus Notif Sound',
        channelDescription:
            'Notifikasi kampus dengan suara dan getaran',

        // Pop-up banner
        importance: Importance.max,
        priority: Priority.high,

        // Suara dan getaran
        playSound: true,
        sound: RawResourceAndroidNotificationSound(
          notificationSoundName,
        ),
        enableVibration: true,

        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: '$notificationSoundName.wav',
      ),
    ),
    payload: message.data['route']?.toString(),
  );

  debugPrint('Notifikasi dengan suara berhasil ditampilkan');
}

// ==========================================
// 5. FCM TOKEN LIFECYCLE
// ==========================================

Future<void> initFcmToken() async {
  try {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    final token = await FirebaseMessaging.instance
        .getToken()
        .timeout(const Duration(seconds: 30));

    if (token != null && token.isNotEmpty) {
      debugPrint(
        'FCM Token: ${token.substring(0, 12)}...',
      );
    } else {
      debugPrint('FCM Token belum tersedia');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        debugPrint('FCM Token berhasil diperbarui');
        debugPrint(
          'FCM Token: ${newToken.substring(0, 12)}...',
        );
      },
      onError: (error) {
        debugPrint('Token refresh error: $error');
      },
    );

    debugPrint('FCM Token listener aktif');
  } catch (e, stackTrace) {
    debugPrint('Gagal mengambil FCM Token: $e');
    debugPrintStack(stackTrace: stackTrace);
  }
}

// ==========================================
// 6. INITIALIZE PUSH SERVICE
// ==========================================

Future<void> initializePushService({
  required Future<void> Function(RemoteMessage message)
      onForegroundMessage,
  required void Function(String? route) onNotificationTap,
}) async {
  _onNotificationTap = onNotificationTap;

  await initLocalNotifications(
    onTap: onNotificationTap,
  );

  final permission = await requestNotificationPermission();

  debugPrint('Permission: $permission');

  // Ambil token tanpa bergantung pada izin notifikasi.
  await initFcmToken();

  // Subscribe topic kampus.
  await FirebaseMessaging.instance.subscribeToTopic(
    'pengumuman-kampus',
  );

  debugPrint('Subscribe pengumuman-kampus berhasil');

  // FOREGROUND
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      await onForegroundMessage(message);

      await showLocalNotification(message);
    },
  );

  // BACKGROUND: notifikasi diklik.
  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) {
      final route = message.data['route']?.toString();

      onNotificationTap(route);
    },
  );

  // TERMINATED: aplikasi dibuka dari notifikasi.
  final initialMessage =
      await FirebaseMessaging.instance.getInitialMessage();

  if (initialMessage != null) {
    final route = initialMessage.data['route']?.toString();

    onNotificationTap(route);
  }
}

// ==========================================
// 7. TOPIC MANAGEMENT
// ==========================================

Future<void> subscribeCampusTopic() async {
  await FirebaseMessaging.instance.subscribeToTopic(
    'pengumuman-kampus',
  );
}

Future<void> unsubscribeCampusTopic() async {
  await FirebaseMessaging.instance.unsubscribeFromTopic(
    'pengumuman-kampus',
  );
}
