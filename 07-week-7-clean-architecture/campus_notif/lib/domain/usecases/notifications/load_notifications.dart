import '../../entities/app_notification.dart';
import '../../repositories/notification_repository.dart';

class LoadNotifications {
  const LoadNotifications(this._repository);

  final NotificationRepository _repository;

  Future<List<AppNotification>> call() => _repository.load();
}
