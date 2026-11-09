import '../../repositories/notification_repository.dart';

class AddNotification {
  const AddNotification(this._repository);

  final NotificationRepository _repository;

  Future<void> call({
    required String id,
    required String title,
    required String body,
    String? route,
  }) {
    return _repository.add(id: id, title: title, body: body, route: route);
  }
}
