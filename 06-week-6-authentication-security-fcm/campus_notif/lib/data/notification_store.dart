
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. MODEL NOTIFIKASI
// ==========================================

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    this.route,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
  final String? route;
  final bool isRead;

  // ========================================
  // MENGUBAH NOTIFIKASI MENJADI JSON
  // ========================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'date': date.toIso8601String(),
      'route': route,
      'isRead': isRead,
    };
  }

  // ========================================
  // MEMBACA NOTIFIKASI DARI JSON
  // ========================================

  factory AppNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return AppNotification(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'Campus Notif',
      body: json['body']?.toString() ?? '',
      date: DateTime.tryParse(
            json['date']?.toString() ?? '',
          ) ??
          DateTime.now(),
      route: json['route']?.toString(),
      isRead: json['isRead'] == true,
    );
  }
}

// ==========================================
// 2. NOTIFICATION STORE
// ==========================================

class NotificationStore {
  static const String _key = 'campus_notifications';

  // ========================================
  // 3. MEMBACA NOTIFIKASI
  // ========================================

  Future<List<AppNotification>> load() async {
    try {
      debugPrint('Mulai membaca notifikasi lokal');

      final prefs = await SharedPreferences.getInstance();

      debugPrint('SharedPreferences berhasil dibuka');

      final data = prefs.getString(_key);

      if (data == null || data.isEmpty) {
        debugPrint('Belum ada notifikasi tersimpan');
        return [];
      }

      final decoded = jsonDecode(data);

      if (decoded is! List) {
        debugPrint('Format data notifikasi tidak valid');
        return [];
      }

      final notifications = decoded.map((item) {
        return AppNotification.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();

      // Notifikasi terbaru ditampilkan paling atas.
      notifications.sort(
        (a, b) => b.date.compareTo(a.date),
      );

      debugPrint(
        'Jumlah notifikasi: ${notifications.length}',
      );

      return notifications;
    } catch (e, stackTrace) {
      debugPrint('ERROR NOTIFICATION STORE LOAD: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ========================================
  // 4. MENYIMPAN NOTIFIKASI
  // ========================================

  Future<void> save(
    List<AppNotification> notifications,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = jsonEncode(
        notifications.map((e) => e.toJson()).toList(),
      );

      await prefs.setString(_key, data);

      debugPrint('Notifikasi berhasil disimpan');
    } catch (e, stackTrace) {
      debugPrint('ERROR NOTIFICATION STORE SAVE: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ========================================
  // 5. MENAMBAHKAN NOTIFIKASI BARU
  // ========================================

  Future<void> add({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    try {
      final notifications = await load();

      // Mencegah notifikasi yang sama tersimpan dua kali.
      final exists = notifications.any(
        (item) => item.id == id,
      );

      if (exists) {
        debugPrint('Notifikasi sudah tersedia: $id');
        return;
      }

      notifications.insert(
        0,
        AppNotification(
          id: id,
          title: title,
          body: body,
          date: DateTime.now(),
          route: route,
          isRead: false,
        ),
      );

      await save(notifications);

      debugPrint('Notifikasi baru ditambahkan: $title');
    } catch (e, stackTrace) {
      debugPrint('ERROR ADD NOTIFICATION: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ========================================
  // 6. MENANDAI NOTIFIKASI SUDAH DIBACA
  // ========================================

  Future<void> markAsRead(String id) async {
    try {
      final notifications = await load();

      // Notifikasi yang dibaca langsung hilang dari list.
      notifications.removeWhere(
        (item) => item.id == id,
      );

      await save(notifications);

      debugPrint('Notifikasi sudah dibaca: $id');
    } catch (e, stackTrace) {
      debugPrint('ERROR MARK AS READ: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ========================================
  // 7. HAPUS SATU NOTIFIKASI
  // ========================================

  Future<void> remove(String id) async {
    try {
      final notifications = await load();

      notifications.removeWhere(
        (item) => item.id == id,
      );

      await save(notifications);

      debugPrint('Notifikasi dihapus: $id');
    } catch (e, stackTrace) {
      debugPrint('ERROR REMOVE NOTIFICATION: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // ========================================
  // 8. MENGHITUNG NOTIFIKASI BELUM DIBACA
  // ========================================

  Future<int> unreadCount() async {
    final notifications = await load();

    return notifications.where(
      (item) => !item.isRead,
    ).length;
  }

  // ========================================
  // 9. MENGHAPUS SEMUA NOTIFIKASI
  // ========================================

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_key);

      debugPrint('Semua notifikasi berhasil dihapus');
    } catch (e, stackTrace) {
      debugPrint('ERROR CLEAR NOTIFICATIONS: $e');
      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }
}
