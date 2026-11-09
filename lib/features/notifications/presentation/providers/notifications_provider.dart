import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notifications_model.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsState {
  const NotificationsState({
    required this.model,
    this.isLoading = false,
    this.errorMessage,
  });

  final NotificationsPageModel model;
  final bool isLoading;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsPageModel? model,
    bool? isLoading,
    String? errorMessage,
  }) {
    return NotificationsState(
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class NotificationsNotifier extends Notifier<NotificationsState> {
  final NotificationsRepository _repository = NotificationsRepository();

  @override
  NotificationsState build() {
    Future.microtask(() => loadNotifications());
    return const NotificationsState(
      model: NotificationsPageModel(
        title: 'Notifications',
        actionText: 'Mark all read',
        sections: [],
        unreadCount: 0,
      ),
      isLoading: true,
    );
  }

  /// Fetch notifications from backend
  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final model = await _repository.getNotifications();
      state = state.copyWith(
        isLoading: false,
        model: model,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshNotifications() async {
    await loadNotifications();
  }

  /// Register FCM device token for order sound alerts
  Future<bool> registerDeviceToken(
    String fcmToken, {
    String platform = 'android',
  }) async {
    try {
      return await _repository.registerDeviceToken(
        fcmToken: fcmToken,
        platform: platform,
      );
    } catch (_) {
      return false;
    }
  }

  void markAllRead() {
    final updatedSections = state.model.sections.map((section) {
      final updatedItems = section.items.map((item) {
        return item.copyWith(isUnread: false);
      }).toList();
      return NotificationsSection(
        sectionTitle: section.sectionTitle,
        items: updatedItems,
      );
    }).toList();

    state = state.copyWith(
      model: NotificationsPageModel(
        title: state.model.title,
        actionText: state.model.actionText,
        sections: updatedSections,
        unreadCount: 0,
      ),
    );

    // Sync with backend asynchronously
    _repository.markNotificationsRead();
  }

  void markItemRead(String itemId) {
    final updatedSections = state.model.sections.map((section) {
      final updatedItems = section.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isUnread: false);
        }
        return item;
      }).toList();
      return NotificationsSection(
        sectionTitle: section.sectionTitle,
        items: updatedItems,
      );
    }).toList();

    state = state.copyWith(
      model: NotificationsPageModel(
        title: state.model.title,
        actionText: state.model.actionText,
        sections: updatedSections,
        unreadCount: (state.model.unreadCount - 1).clamp(0, 999),
      ),
    );

    // Sync with backend asynchronously
    _repository.markNotificationsRead(notificationIds: [itemId]);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, NotificationsState>(
  NotificationsNotifier.new,
);
