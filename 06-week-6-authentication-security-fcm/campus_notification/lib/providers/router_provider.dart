import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/home_page.dart';
import '../screens/announcement_page.dart';
import '../screens/announcement_detail_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/announcements',
        builder: (context, state) =>
            const AnnouncementPage(),
      ),
      GoRoute(
        path: '/announcements/:id',
        builder: (context, state) =>
            AnnouncementDetailPage(
          id: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});