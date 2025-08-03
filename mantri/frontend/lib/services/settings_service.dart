import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  static const String _notificationsKey = 'notifications_enabled';
  static const String _darkModeKey = 'dark_mode_enabled';
  static const String _autoSaveKey = 'auto_save_enabled';
  static const String _weeklyRemindersKey = 'weekly_reminders_enabled';
  static const String _languageKey = 'selected_language';

  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();

    final notificationsEnabled = await getNotificationsEnabled();
    if (notificationsEnabled) {
      await _notificationService.scheduleDailyReminder();
    }
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);

    if (enabled) {
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelNotification(0);
    }
  }

  Future<bool> getDarkModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  Future<bool> getAutoSaveEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoSaveKey) ?? true;
  }

  Future<void> setAutoSaveEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoSaveKey, enabled);
  }

  Future<bool> getWeeklyRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_weeklyRemindersKey) ?? true;
  }

  Future<void> setWeeklyRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weeklyRemindersKey, enabled);

    if (enabled) {
      await _notificationService.scheduleWeeklyReminder();
    } else {
      await _notificationService.cancelNotification(1);
    }
  }

  Future<String> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'English';
  }

  Future<void> setSelectedLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<void> resetAllSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    await setNotificationsEnabled(true);
    await setDarkModeEnabled(false);
    await setAutoSaveEnabled(true);
    await setWeeklyRemindersEnabled(true);
    await setSelectedLanguage('English');
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final notificationsEnabled = await getNotificationsEnabled();
    if (notificationsEnabled) {
      await _notificationService.showInstantNotification(
        title: title,
        body: body,
        payload: payload,
      );
    }
  }
}
