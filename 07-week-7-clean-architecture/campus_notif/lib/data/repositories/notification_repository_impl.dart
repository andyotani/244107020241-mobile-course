import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_local_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._localDataSource);

  final NotificationLocalDataSource _localDataSource;

  @override
  Future<List<AppNotification>> load() => _localDataSource.load();

  @override
  Future<void> add({
    required String id,
    required String title,
    required String body,
    String? route,
  }) {
    return _localDataSource.add(id: id, title: title, body: body, route: route);
  }

  @override
  Future<void> remove(String id) => _localDataSource.remove(id);

  @override
  Future<void> clear() => _localDataSource.clear();
}
