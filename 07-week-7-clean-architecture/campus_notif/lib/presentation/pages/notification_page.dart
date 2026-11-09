import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/notification_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Hapus semua',
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final items = ref.read(notificationProvider).value ?? [];

              if (items.isEmpty) return;

              await ref.read(notificationProvider.notifier).clearAll();
            },
          ),
        ],
      ),

      body: notificationState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) =>
            Center(child: Text('Terjadi kesalahan: $error')),

        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 75,
                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Belum ada notifikasi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text('Pengumuman kampus akan muncul di sini.'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,

            itemBuilder: (context, index) {
              final item = notifications[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),

                  leading: CircleAvatar(
                    backgroundColor: item.isRead
                        ? Colors.grey.shade300
                        : Colors.blue.shade100,
                    child: Icon(
                      Icons.notifications,
                      color: item.isRead ? Colors.grey : Colors.blue,
                    ),
                  ),

                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: item.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),

                      Text(item.body),

                      const SizedBox(height: 8),

                      Text(
                        '${item.date.day}/${item.date.month}/${item.date.year} '
                        '${item.date.hour.toString().padLeft(2, '0')}:'
                        '${item.date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      await ref
                          .read(notificationProvider.notifier)
                          .deleteNotification(item.id);
                    },
                  ),

                  onTap: () async {
                    // Notifikasi langsung hilang saat dibaca.
                    await ref
                        .read(notificationProvider.notifier)
                        .markAsRead(item.id);

                    if (!context.mounted) return;

                    final route = item.route;

                    // Rute hanya diarahkan ke halaman yang tersedia.
                    if (route == '/notifications') {
                      return;
                    }

                    if (route == '/' || route == '/login') {
                      context.go(route!);
                    } else {
                      context.go('/');
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
