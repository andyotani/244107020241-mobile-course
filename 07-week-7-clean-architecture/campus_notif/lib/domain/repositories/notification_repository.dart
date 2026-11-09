import '../entities/app_notification.dart';

abstract interface class NotificationRepository {
  Future<List<AppNotification>> load();

  Future<void> add({
    required String id,
    required String title,
    required String body,
    String? route,
  });

  Future<void> remove(String id);

  Future<void> clear();
}
