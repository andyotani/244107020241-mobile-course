import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/notification_local_data_source.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/usecases/notifications/add_notification.dart';
import '../../domain/usecases/notifications/clear_notifications.dart';
import '../../domain/usecases/notifications/load_notifications.dart';
import '../../domain/usecases/notifications/remove_notification.dart';

final notificationLocalDataSourceProvider =
    Provider<NotificationLocalDataSource>((ref) {
      return NotificationLocalDataSource();
    });

final notificationRepositoryProvider = Provider<NotificationRepositoryImpl>((
  ref,
) {
  return NotificationRepositoryImpl(
    ref.read(notificationLocalDataSourceProvider),
  );
});

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<AppNotification>>(
      NotificationNotifier.new,
    );

class NotificationNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    final repository = ref.read(notificationRepositoryProvider);
    return LoadNotifications(repository)();
  }

  int get unreadCount {
    final notifications = state.value ?? [];
    return notifications.where((notification) => !notification.isRead).length;
  }

  Future<void> addNotification({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    final repository = ref.read(notificationRepositoryProvider);
    await AddNotification(repository)(
      id: id,
      title: title,
      body: body,
      route: route,
    );
    state = AsyncData(await LoadNotifications(repository)());
  }

  Future<void> markAsRead(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    await RemoveNotification(repository)(id);
    state = AsyncData(await LoadNotifications(repository)());
  }

  Future<void> deleteNotification(String id) async {
    final repository = ref.read(notificationRepositoryProvider);
    await RemoveNotification(repository)(id);
    state = AsyncData(await LoadNotifications(repository)());
  }

  Future<void> clearAll() async {
    final repository = ref.read(notificationRepositoryProvider);
    await ClearNotifications(repository)();
    state = const AsyncData([]);
  }

  Future<void> refreshNotifications() async {
    final repository = ref.read(notificationRepositoryProvider);
    state = AsyncData(await LoadNotifications(repository)());
  }
}
