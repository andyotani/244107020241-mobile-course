import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.date,
    super.route,
    super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title']?.toString() ?? 'Campus Notif',
      body: json['body']?.toString() ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      route: json['route']?.toString(),
      isRead: json['isRead'] == true,
    );
  }

  factory NotificationModel.fromEntity(AppNotification notification) {
    return NotificationModel(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      date: notification.date,
      route: notification.route,
      isRead: notification.isRead,
    );
  }

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
}
