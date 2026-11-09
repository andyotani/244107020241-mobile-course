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
}
