import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/notification_model.dart';

class NotificationLocalDataSource {
  static const String _key = 'campus_notifications';

  Future<List<NotificationModel>> load() async {
    try {
      debugPrint('Mulai membaca notifikasi lokal');

      final prefs = await SharedPreferences.getInstance();
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

      final notifications = decoded
          .map(
            (item) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      notifications.sort((a, b) => b.date.compareTo(a.date));

      debugPrint('Jumlah notifikasi: ${notifications.length}');
      return notifications;
    } catch (error, stackTrace) {
      debugPrint('ERROR NOTIFICATION STORE LOAD: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> save(List<NotificationModel> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(
        notifications.map((notification) => notification.toJson()).toList(),
      );
      await prefs.setString(_key, data);
      debugPrint('Notifikasi berhasil disimpan');
    } catch (error, stackTrace) {
      debugPrint('ERROR NOTIFICATION STORE SAVE: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> add({
    required String id,
    required String title,
    required String body,
    String? route,
  }) async {
    try {
      final notifications = await load();
      if (notifications.any((notification) => notification.id == id)) {
        debugPrint('Notifikasi sudah tersedia: $id');
        return;
      }

      notifications.insert(
        0,
        NotificationModel(
          id: id,
          title: title,
          body: body,
          date: DateTime.now(),
          route: route,
        ),
      );
      await save(notifications);
      debugPrint('Notifikasi baru ditambahkan: $title');
    } catch (error, stackTrace) {
      debugPrint('ERROR ADD NOTIFICATION: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> remove(String id) async {
    try {
      final notifications = await load();
      notifications.removeWhere((notification) => notification.id == id);
      await save(notifications);
      debugPrint('Notifikasi dihapus: $id');
    } catch (error, stackTrace) {
      debugPrint('ERROR REMOVE NOTIFICATION: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      debugPrint('Semua notifikasi berhasil dihapus');
    } catch (error, stackTrace) {
      debugPrint('ERROR CLEAR NOTIFICATIONS: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
