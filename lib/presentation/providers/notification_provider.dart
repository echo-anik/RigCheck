import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/notification_service.dart';

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for all notifications
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.notifications;
});

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.unreadCount;
});

/// Provider for notification stream (real-time updates)
final notificationStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return service.notificationStream;
});

/// Provider for filtered notifications
final filteredNotificationsProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, filter) async {
  final notifications = await ref.watch(notificationsProvider.future);
  
  if (filter == 'all') {
    return notifications;
  } else if (filter == 'unread') {
    return notifications.where((n) => !n.isRead).toList();
  } else {
    return notifications.where((n) => n.type == filter).toList();
  }
});

/// State class for notification preferences
class NotificationPreferences {
  final bool pushEnabled;
  final bool likesEnabled;
  final bool commentsEnabled;
  final bool sharesEnabled;
  final bool followsEnabled;
  final bool buildUpdatesEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationPreferences({
    this.pushEnabled = true,
    this.likesEnabled = true,
    this.commentsEnabled = true,
    this.sharesEnabled = true,
    this.followsEnabled = true,
    this.buildUpdatesEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  NotificationPreferences copyWith({
    bool? pushEnabled,
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? sharesEnabled,
    bool? followsEnabled,
    bool? buildUpdatesEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationPreferences(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      likesEnabled: likesEnabled ?? this.likesEnabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      sharesEnabled: sharesEnabled ?? this.sharesEnabled,
      followsEnabled: followsEnabled ?? this.followsEnabled,
      buildUpdatesEnabled: buildUpdatesEnabled ?? this.buildUpdatesEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'likesEnabled': likesEnabled,
      'commentsEnabled': commentsEnabled,
      'sharesEnabled': sharesEnabled,
      'followsEnabled': followsEnabled,
      'buildUpdatesEnabled': buildUpdatesEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      likesEnabled: json['likesEnabled'] as bool? ?? true,
      commentsEnabled: json['commentsEnabled'] as bool? ?? true,
      sharesEnabled: json['sharesEnabled'] as bool? ?? true,
      followsEnabled: json['followsEnabled'] as bool? ?? true,
      buildUpdatesEnabled: json['buildUpdatesEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );
  }
}

/// Notifier for notification preferences
class NotificationPreferencesNotifier extends StateNotifier<NotificationPreferences> {
  NotificationPreferencesNotifier() : super(NotificationPreferences());

  void updatePreference({
    bool? pushEnabled,
    bool? likesEnabled,
    bool? commentsEnabled,
    bool? sharesEnabled,
    bool? followsEnabled,
    bool? buildUpdatesEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    state = state.copyWith(
      pushEnabled: pushEnabled,
      likesEnabled: likesEnabled,
      commentsEnabled: commentsEnabled,
      sharesEnabled: sharesEnabled,
      followsEnabled: followsEnabled,
      buildUpdatesEnabled: buildUpdatesEnabled,
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
    );
    _savePreferences();
  }

  Future<void> _savePreferences() async {
    // TODO: Save to SharedPreferences
  }

  Future<void> loadPreferences() async {
    // TODO: Load from SharedPreferences
  }
}

final notificationPreferencesProvider =
    StateNotifierProvider<NotificationPreferencesNotifier, NotificationPreferences>((ref) {
  return NotificationPreferencesNotifier();
});
