
import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../firebase_options.dart';

// ======================================================
// 1. GLOBAL LOCAL NOTIFICATION PLUGIN
// ======================================================

final FlutterLocalNotificationsPlugin localNotifications =
    FlutterLocalNotificationsPlugin();

// ======================================================
// 2. ANDROID NOTIFICATION CHANNEL
// ======================================================

const AndroidNotificationChannel notificationChannel =
    AndroidNotificationChannel(
  'campus_notification_channel',
  'Campus Notifications',
  description: 'Notifikasi informasi dan pengumuman kampus',
  importance: Importance.high,
);

// ======================================================
// 3. BACKGROUND MESSAGE HANDLER
//
// WAJIB:
// - Top-level function.
// - Menggunakan @pragma('vm:entry-point').
// - Tidak boleh menggunakan BuildContext.
// - Tidak boleh mengakses widget tree.
// ======================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {

  // Initialize Firebase pada background isolate.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('================================');
  debugPrint('BACKGROUND NOTIFICATION');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Data: ${message.data}');
  debugPrint('================================');

  // Notification payload ditampilkan otomatis
  // oleh sistem operasi ketika aplikasi background.

  // Data-only message ditampilkan secara manual.
  if (message.notification == null) {

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      ),
      iOS: DarwinInitializationSettings(),
    );

    // Initialize local notification.
    await localNotifications.initialize(
      settings: initializationSettings,
    );

    // Buat Android notification channel.
    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          notificationChannel,
        );

    final title =
        message.data['title'] ?? 'Campus Notification';

    final body =
        message.data['body'] ?? 'Ada informasi baru';

    // Tampilkan local notification.
    await localNotifications.show(
      id: message.messageId?.hashCode.abs() ??
          DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannel.id,
          notificationChannel.name,
          channelDescription:
              notificationChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data['route'],
    );
  }
}

// ======================================================
// 4. PUSH SERVICE
// ======================================================

class PushService {

  // Firebase Messaging.
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  // GoRouter.
  // Navigasi tidak membutuhkan BuildContext.
  final GoRouter router;

  PushService({
    required this.router,
  });

  // Menyimpan semua listener.
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  bool _initialized = false;

  // ====================================================
  // 5. INITIALIZE PUSH SERVICE
  // ====================================================

  Future<void> initialize() async {

    if (_initialized) return;

    debugPrint('Initializing Push Service...');

    // Initialize local notification.
    await _initializeLocalNotification();

    // Request notification permission.
    await requestPermission();

    // Get FCM token.
    await getToken();

    // ================================================
    // TOKEN REFRESH
    // ================================================

    _subscriptions.add(
      _messaging.onTokenRefresh.listen(
        (newToken) {

          debugPrint('================================');
          debugPrint('FCM TOKEN UPDATED');
          debugPrint(newToken);
          debugPrint('================================');

          // TANPA BACKEND:
          // Token hanya ditampilkan di Debug Console.
          // Tidak dikirim ke POST /devices.
        },
        onError: (error) {
          debugPrint('Token refresh error: $error');
        },
      ),
    );

    // ================================================
    // FOREGROUND MESSAGE
    // ================================================

    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(
        (message) async {

          debugPrint('Foreground notification received');

          await _showLocalNotification(message);
        },
        onError: (error) {
          debugPrint('Foreground message error: $error');
        },
      ),
    );

    // ================================================
    // BACKGROUND -> OPENED APP
    // ================================================

    _subscriptions.add(
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) {

          debugPrint('Notification opened from background');

          _navigateFromMessage(message);
        },
        onError: (error) {
          debugPrint('Notification navigation error: $error');
        },
      ),
    );

    // ================================================
    // TERMINATED -> OPENED APP
    // ================================================

    final initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {

      debugPrint('App opened from terminated state');

      _navigateFromMessage(initialMessage);
    }

    // ================================================
    // LOCAL NOTIFICATION LAUNCH
    // ================================================

    final launchDetails =
        await localNotifications.getNotificationAppLaunchDetails();

    final response = launchDetails?.notificationResponse;

    if (launchDetails?.didNotificationLaunchApp == true &&
        response?.payload != null &&
        response!.payload!.isNotEmpty) {

      _navigateToRoute(response.payload!);
    }

    _initialized = true;

    debugPrint('Push Service initialized successfully');
  }

  // ====================================================
  // 6. REQUEST PERMISSION
  // ====================================================

  Future<NotificationSettings> requestPermission() async {

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('================================');
    debugPrint('NOTIFICATION PERMISSION');
    debugPrint(
      'Status: ${settings.authorizationStatus}',
    );
    debugPrint('================================');

    // ANDROID 13+:
    // Memerlukan runtime permission POST_NOTIFICATIONS.
    // Firebase Messaging requestPermission menangani
    // permintaan izin notifikasi.

    // iOS:
    // Meminta izin Alert, Badge, dan Sound.

    return settings;
  }

  // ====================================================
  // 7. GET FCM TOKEN
  // ====================================================

  Future<String?> getToken() async {

    try {

      // ==============================================
      // iOS APNs TOKEN
      // ==============================================

      if (!kIsWeb && Platform.isIOS) {

        String? apnsToken;

        // Tunggu APNs token tersedia.
        for (int i = 0; i < 10 && apnsToken == null; i++) {

          apnsToken = await _messaging.getAPNSToken();

          if (apnsToken == null) {

            await Future.delayed(
              const Duration(seconds: 1),
            );
          }
        }

        if (apnsToken == null) {

          debugPrint('APNs token belum tersedia');

          return null;
        }
      }

      // ==============================================
      // GET FIREBASE TOKEN
      // ==============================================

      final token = await _messaging.getToken();

      if (token != null) {

        debugPrint('================================');
        debugPrint('FCM DEVICE TOKEN');
        debugPrint(token);
        debugPrint('================================');

      } else {

        debugPrint('FCM Token belum tersedia');
      }

      // TANPA BACKEND:
      // Token hanya ditampilkan di Debug Console.
      // Gunakan token untuk pengujian Firebase Console.

      return token;

    } catch (e) {

      debugPrint('Get FCM Token Error: $e');

      return null;
    }
  }

  // ====================================================
  // 8. INITIALIZE LOCAL NOTIFICATION
  // ====================================================

  Future<void> _initializeLocalNotification() async {

    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // ==============================================
    // INITIALIZE PLUGIN
    // ==============================================

    await localNotifications.initialize(
      settings: initializationSettings,

      onDidReceiveNotificationResponse: (response) {

        final route = response.payload;

        if (route != null && route.isNotEmpty) {

          debugPrint('Local notification clicked');

          _navigateToRoute(route);
        }
      },
    );

    // ==============================================
    // ANDROID NOTIFICATION CHANNEL
    // ==============================================

    await localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          notificationChannel,
        );

    // ==============================================
    // iOS FOREGROUND PRESENTATION
    // ==============================================

    if (!kIsWeb && Platform.isIOS) {

      await _messaging
          .setForegroundNotificationPresentationOptions(
        alert: false,
        badge: false,
        sound: false,
      );
    }

    debugPrint('Local Notification initialized');
  }

  // ====================================================
  // 9. SHOW LOCAL NOTIFICATION
  // ====================================================

  Future<void> _showLocalNotification(
      RemoteMessage message) async {

    final title =
        message.notification?.title ??
        message.data['title'] ??
        'Campus Notification';

    final body =
        message.notification?.body ??
        message.data['body'] ??
        'Ada informasi baru dari kampus';

    await localNotifications.show(
      id: message.messageId?.hashCode.abs() ??
          DateTime.now().millisecondsSinceEpoch,

      title: title,

      body: body,

      notificationDetails: NotificationDetails(

        // ==========================================
        // ANDROID
        // ==========================================

        android: AndroidNotificationDetails(
          notificationChannel.id,
          notificationChannel.name,
          channelDescription:
              notificationChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),

        // ==========================================
        // iOS
        // ==========================================

        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),

      // Data untuk navigasi.
      payload: message.data['route'],
    );

    debugPrint('Local notification displayed');
  }

  // ====================================================
  // 10. NAVIGATION FROM MESSAGE
  //
  // TIDAK MENGGUNAKAN BuildContext.
  // ====================================================

  void _navigateFromMessage(RemoteMessage message) {

    final route = message.data['route'];

    if (route != null && route.isNotEmpty) {

      _navigateToRoute(route);

    } else {

      debugPrint('Notification does not contain route');
    }
  }

  // ====================================================
  // 11. NAVIGATE TO ROUTE
  // ====================================================

  void _navigateToRoute(String route) {

    // Validasi route internal.
    if (!route.startsWith('/') ||
        route.startsWith('//')) {

      debugPrint('Invalid notification route: $route');

      return;
    }

    debugPrint('Navigate to: $route');

    // Navigasi menggunakan GoRouter.
    // Tidak membutuhkan BuildContext.
    router.go(route);
  }

  // ====================================================
  // 12. SUBSCRIBE TOPIC
  // ====================================================

  Future<void> subscribeAnnouncement() async {

    try {

      await _messaging.subscribeToTopic(
        'pengumuman-kampus',
      );

      debugPrint(
        'Successfully subscribed to pengumuman-kampus',
      );

    } catch (e) {

      debugPrint('Subscribe topic error: $e');
    }
  }

  // ====================================================
  // 13. UNSUBSCRIBE TOPIC
  // ====================================================

  Future<void> unsubscribeAnnouncement() async {

    try {

      await _messaging.unsubscribeFromTopic(
        'pengumuman-kampus',
      );

      debugPrint(
        'Successfully unsubscribed from pengumuman-kampus',
      );

    } catch (e) {

      debugPrint('Unsubscribe topic error: $e');
    }
  }

  // ====================================================
  // 14. DISPOSE LISTENERS
  // ====================================================

  void dispose() {

    for (final subscription in _subscriptions) {

      unawaited(subscription.cancel());
    }

    _subscriptions.clear();

    _initialized = false;

    debugPrint('Push Service disposed');
  }
}
