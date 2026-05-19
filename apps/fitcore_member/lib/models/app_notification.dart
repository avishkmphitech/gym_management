/// In-app notification item (mock push / alert center).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.category,
    this.read = false,
    this.memberId,
    this.memberName,
    this.severity = AppNotificationSeverity.info,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final AppNotificationCategory category;
  final bool read;
  final String? memberId;
  final String? memberName;
  final AppNotificationSeverity severity;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      timeLabel: timeLabel,
      category: category,
      read: read ?? this.read,
      memberId: memberId,
      memberName: memberName,
      severity: severity,
    );
  }
}

enum AppNotificationCategory {
  planAssigned,
  planUpdated,
  sessionReminder,
  memberCheckIn,
  overstayCheckout,
  system,
}

enum AppNotificationSeverity { info, warning, critical }
