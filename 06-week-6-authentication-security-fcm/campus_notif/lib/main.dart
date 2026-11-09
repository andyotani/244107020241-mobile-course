
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'firebase_options.dart';

import 'messaging/push_service.dart';

import 'providers/auth_provider.dart';
import 'providers/notification_provider.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/notification_page.dart';

// ==========================================
// 1. ROUTER PROVIDER
// ==========================================

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',

    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading) {
        return null;
      }

      final loggedIn = authState.value ?? false;

      final goingLogin =
          state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) {
        return '/login';
      }

      if (loggedIn && goingLogin) {
        return '/';
      }

      return null;
    },

    routes: [
      // LOGIN
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      // HOME
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const HomePage();
        },
      ),

      // NOTIFICATION
      GoRoute(
        path: '/notifications',
        builder: (context, state) {
          return const NotificationPage();
        },
      ),
    ],
  );

  // Refresh ketika status login berubah.
  ref.listen(authStateProvider, (previous, next) {
    router.refresh();
  });

  ref.onDispose(() {
    router.dispose();
  });

  return router;
});

// ==========================================
// 2. MAIN FUNCTION
// ==========================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inisialisasi Firebase.
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Firebase berhasil diinisialisasi');

    // Background handler.
    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );

    runApp(
      const ProviderScope(
        child: CampusNotifApp(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Firebase initialization error: $e');

    debugPrintStack(stackTrace: stackTrace);

    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Firebase gagal diinisialisasi:\n$e',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. CAMPUS NOTIF APPLICATION
// ==========================================

class CampusNotifApp extends ConsumerStatefulWidget {
  const CampusNotifApp({super.key});

  @override
  ConsumerState<CampusNotifApp> createState() =>
      _CampusNotifAppState();
}

class _CampusNotifAppState
    extends ConsumerState<CampusNotifApp> {

  bool pushInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializePush();
    });
  }

  // ========================================
  // 4. INITIALIZE PUSH
  // ========================================

  Future<void> initializePush() async {
    if (pushInitialized) return;

    pushInitialized = true;

    try {
      await initializePushService(
        // FOREGROUND MESSAGE
        onForegroundMessage: (RemoteMessage message) async {
          final notification = message.notification;

          if (notification == null) return;

          final id = message.messageId ??
              message.hashCode.toString();

          await ref
              .read(notificationProvider.notifier)
              .addNotification(
                id: id,
                title: notification.title ?? 'Campus Notif',
                body: notification.body ?? '',
                route: message.data['route']?.toString(),
              );

          debugPrint('Notifikasi masuk ke daftar');
        },

        // NOTIFICATION CLICK
        onNotificationTap: (String? route) {
          debugPrint('Notification clicked: $route');

          if (!mounted) return;

          final router = ref.read(routerProvider);

          // Arahkan ke halaman notifikasi.
          // Pengguna dapat membaca pesan dari daftar.
          if (route == '/') {
            router.go('/');
          } else {
            router.go('/notifications');
          }
        },
      );

      debugPrint('Campus Notif Push berhasil dijalankan');

    } catch (e, stackTrace) {
      debugPrint('Push initialization error: $e');

      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // ========================================
  // 5. BUILD APPLICATION
  // ========================================

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,

      title: 'Campus Notif',

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),

      routerConfig: router,
    );
  }
}
