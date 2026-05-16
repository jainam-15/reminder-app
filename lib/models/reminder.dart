import 'dart:convert';

/// Reminder data model with persistence support.
class Reminder {
  final String id;
  final String message;
  final DateTime createdAt;
  final DateTime scheduledFor;

  Reminder({
    required this.id,
    required this.message,
    required this.createdAt,
    required this.scheduledFor,
  });

  /// Whether the 30-second notification hasn't fired yet.
  bool get isActive => DateTime.now().isBefore(scheduledFor);

  /// Human-readable relative timestamp.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  /// Formatted time (e.g., "11:45 PM").
  String get formattedTime {
    final h = createdAt.hour;
    final m = createdAt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hour12:$m $period';
  }

  /// Formatted date (e.g., "May 16, 2026").
  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[createdAt.month - 1]} ${createdAt.day}, ${createdAt.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
        'scheduledFor': scheduledFor.toIso8601String(),
      };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        scheduledFor: json['scheduledFor'] != null
            ? DateTime.parse(json['scheduledFor'] as String)
            : DateTime.parse(json['createdAt'] as String)
                .add(const Duration(seconds: 30)),
      );

  static String encodeList(List<Reminder> reminders) =>
      jsonEncode(reminders.map((r) => r.toJson()).toList());

  static List<Reminder> decodeList(String json) =>
      (jsonDecode(json) as List)
          .map((e) => Reminder.fromJson(e as Map<String, dynamic>))
          .toList();
}
