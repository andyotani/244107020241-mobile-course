import '../../repositories/notification_repository.dart';

class RemoveNotification {
  const RemoveNotification(this._repository);

  final NotificationRepository _repository;

  Future<void> call(String id) => _repository.remove(id);
}
