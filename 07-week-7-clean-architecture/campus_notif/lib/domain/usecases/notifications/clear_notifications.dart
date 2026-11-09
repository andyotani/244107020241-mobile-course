import '../../repositories/notification_repository.dart';

class ClearNotifications {
  const ClearNotifications(this._repository);

  final NotificationRepository _repository;

  Future<void> call() => _repository.clear();
}
