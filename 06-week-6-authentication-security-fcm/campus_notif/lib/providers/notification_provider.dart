
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_store.dart';

// ==========================================
// NOTIFICATION STORE PROVIDER
// ==========================================

final notificationStoreProvider =
    Provider<NotificationStore>((ref) {
  return NotificationStore();
});

// ==========================================
// NOTIFICATION STATE PROVIDER
// ==========================================

final notificationProvider =
    AsyncNotifierProvider<
        NotificationNotifier,
        List<AppNotification>>(
  NotificationNotifier.new,
);

class NotificationNotifier
    extends AsyncNotifier<List<AppNotification>> {

  @override
  Future<List<AppNotification>> build() async {
    return ref.read(notificationStoreProvider).load();
  }

  // ========================================
  // JUMLAH NOTIFIKASI BELUM DIBACA
  // ========================================

  int get unreadCount {
    final notifications = state.value ?? [];

    return notifications
        .where((item) => !item.isRead)
        .length;
  }

  // ========================================
  // TAMBAH NOTIFIKASI
  // ========================================

  Future<void> addNotification({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    final store = ref.read(notificationStoreProvider);

    await store.add(
      id: id,
      title: title,
      body: body,
      route: route,
    );

    state = AsyncData(await store.load());
  }

  // ========================================
  // HAPUS NOTIFIKASI SAAT DIBACA
  // ========================================

  Future<void> markAsRead(String id) async {
    final store = ref.read(notificationStoreProvider);

    await store.remove(id);

    state = AsyncData(await store.load());
  }

  // ========================================
  // HAPUS SATU NOTIFIKASI
  // ========================================

  Future<void> deleteNotification(String id) async {
    final store = ref.read(notificationStoreProvider);

    await store.remove(id);

    state = AsyncData(await store.load());
  }

  // ========================================
  // HAPUS SEMUA NOTIFIKASI
  // ========================================

  Future<void> clearAll() async {
    final store = ref.read(notificationStoreProvider);

    await store.clear();

    state = const AsyncData([]);
  }

  // ========================================
  // REFRESH NOTIFIKASI
  // ========================================

  Future<void> refreshNotifications() async {
    final notifications =
        await ref.read(notificationStoreProvider).load();

    state = AsyncData(notifications);
  }
}
