
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'messaging/push_service.dart';

import 'providers/auth_provider.dart';

import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/announcement_page.dart';

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
      final goingLogin = state.matchedLocation == '/login';

      if (!loggedIn && !goingLogin) {
        return '/login';
      }

      if (loggedIn && goingLogin) {
        return '/';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginPage();
        },
      ),

      GoRoute(
        path: '/',
        builder: (context, state) {
          return const HomePage();
        },
      ),

      GoRoute(
        path: '/pengumuman/:id',
        builder: (context, state) {
          return AnnouncementPage(
            id: state.pathParameters['id'] ?? '',
          );
        },
      ),
    ],
  );

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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registrasi background handler
  registerBackgroundHandler();

  // Inisialisasi local notification
  await initLocalNotifications();

  // Meminta izin notifikasi
  final permissionGranted =
      await requestNotificationPermission();

  if (permissionGranted) {
    debugPrint('Notification permission granted');

    // Mengambil dan memantau FCM token
    await initFcmToken(
      onToken: (token) async {
        final shortToken = token.length > 12
            ? '${token.substring(0, 12)}...'
            : token;

        debugPrint('FCM Token: $shortToken');

        // Pengiriman ke backend dilakukan setelah API tersedia.
      },
    );
  } else {
    debugPrint('Notification permission not granted');
  }

  // Menjalankan aplikasi
  runApp(
    const ProviderScope(
      child: CampusNotifyApp(),
    ),
  );
}

// ==========================================
// 3. MAIN APPLICATION
// ==========================================

class CampusNotifyApp extends ConsumerStatefulWidget {
  const CampusNotifyApp({super.key});

  @override
  ConsumerState<CampusNotifyApp> createState() =>
      _CampusNotifyAppState();
}

class _CampusNotifyAppState
    extends ConsumerState<CampusNotifyApp> {

  bool _notificationHandlersInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notificationHandlersInitialized) {
      return;
    }

    _notificationHandlersInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final router = ref.read(routerProvider);

      // Menghubungkan klik local notification dengan GoRouter
      registerNotificationNavigation(router.go);

      // Mengaktifkan foreground dan background listener
      listenForeground(router.go);

      // Memeriksa apakah aplikasi dibuka dari notifikasi
      handleTerminated(router.go);
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Campus Notify',

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
