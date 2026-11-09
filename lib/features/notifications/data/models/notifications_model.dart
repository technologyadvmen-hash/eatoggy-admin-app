class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    this.isUnread = false,
  });

  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final bool isUnread;

  NotificationItem copyWith({
    String? id,
    String? title,
    String? description,
    String? timeAgo,
    bool? isUnread,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeAgo: timeAgo ?? this.timeAgo,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final title = json['title']?.toString() ?? 'Notification';
    final description = json['message']?.toString() ??
        json['description']?.toString() ??
        json['body']?.toString() ??
        '';
    final isRead = json['isRead'] ?? json['read'] ?? false;
    final rawDate =
        json['createdAt']?.toString() ?? json['timestamp']?.toString();
    final timeAgo = _formatTimeAgo(rawDate);

    return NotificationItem(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      isUnread: isRead is bool ? !isRead : true,
    );
  }

  static String _formatTimeAgo(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return 'Recent';
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
        final diff = DateTime.now().difference(parsed.toLocal());
        if (diff.inSeconds < 60) return 'Just now';
        if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
        if (diff.inHours < 24) return '${diff.inHours} hr ago';
        if (diff.inDays == 1) return 'Yesterday';
        if (diff.inDays < 7) return '${diff.inDays} days ago';
        const months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${parsed.day} ${months[parsed.month - 1]}';
      }
    } catch (_) {}
    return 'Recent';
  }
}

class NotificationsSection {
  const NotificationsSection({
    required this.sectionTitle,
    required this.items,
  });

  final String sectionTitle;
  final List<NotificationItem> items;
}

class NotificationsPageModel {
  const NotificationsPageModel({
    required this.title,
    required this.actionText,
    required this.sections,
    this.unreadCount = 0,
  });

  final String title;
  final String actionText;
  final List<NotificationsSection> sections;
  final int unreadCount;

  factory NotificationsPageModel.fromNotificationsList(
    List<NotificationItem> allItems, {
    int unreadCount = 0,
  }) {
    if (allItems.isEmpty) {
      return const NotificationsPageModel(
        title: 'Notifications',
        actionText: 'Mark all read',
        sections: [],
        unreadCount: 0,
      );
    }

    final todayItems = <NotificationItem>[];
    final yesterdayItems = <NotificationItem>[];
    final earlierItems = <NotificationItem>[];

    for (final item in allItems) {
      if (item.timeAgo.contains('min') ||
          item.timeAgo.contains('hr') ||
          item.timeAgo.contains('now')) {
        todayItems.add(item);
      } else if (item.timeAgo.toLowerCase().contains('yesterday')) {
        yesterdayItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    final sections = <NotificationsSection>[];
    if (todayItems.isNotEmpty) {
      sections.add(
        NotificationsSection(sectionTitle: 'TODAY', items: todayItems),
      );
    }
    if (yesterdayItems.isNotEmpty) {
      sections.add(
        NotificationsSection(
            sectionTitle: 'YESTERDAY', items: yesterdayItems),
      );
    }
    if (earlierItems.isNotEmpty) {
      sections.add(
        NotificationsSection(sectionTitle: 'EARLIER', items: earlierItems),
      );
    }

    return NotificationsPageModel(
      title: 'Notifications',
      actionText: 'Mark all read',
      sections: sections,
      unreadCount: unreadCount,
    );
  }

  static const dummy = NotificationsPageModel(
    title: 'Notifications',
    actionText: 'Mark all read',
    unreadCount: 0,
    sections: [],
  );
}
