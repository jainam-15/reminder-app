import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder.dart';

/// Handles persisting and retrieving reminders from local storage.
class ReminderStorage {
  static const _listKey = 'reminders_list';
  static const _messageKey = 'reminder_message';

  /// Save a new reminder to the list and store latest message as flat string.
  static Future<void> saveReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_messageKey, reminder.message);

    final existing = prefs.getString(_listKey);
    final list =
        existing != null ? Reminder.decodeList(existing) : <Reminder>[];
    list.insert(0, reminder);
    if (list.length > 20) list.removeRange(20, list.length);

    await prefs.setString(_listKey, Reminder.encodeList(list));
  }

  /// Retrieve all saved reminders (newest first).
  static Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_listKey);
    if (data == null) return [];
    return Reminder.decodeList(data);
  }

  /// Retrieve the latest flat reminder message (notification fallback).
  static Future<String?> getLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_messageKey);
  }

  /// Delete a reminder by ID.
  static Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_listKey);
    if (data == null) return;

    final list = Reminder.decodeList(data);
    list.removeWhere((r) => r.id == id);
    await prefs.setString(_listKey, Reminder.encodeList(list));
  }

  /// Find a reminder by message text (for notification payload lookups).
  static Future<Reminder?> findByMessage(String message) async {
    final list = await getReminders();
    for (final r in list) {
      if (r.message == message) return r;
    }
    return null;
  }
}
