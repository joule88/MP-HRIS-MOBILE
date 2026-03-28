import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const String _keyJamMasuk = 'reminder_jam_masuk';
  static const String _keyJamPulang = 'reminder_jam_pulang';

  static const int _baseIdMasuk = 1001;
  static const int _baseIdPulang = 2001;
  static const int _baseIdLupa = 3001;
  static const int _daysAhead = 7;
  static const int _minutesBefore = 15;
  static const int _minutesAfterForLupa = 30;

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings: initSettings);
  }

  Future<void> scheduleWeeklyReminders({
    required String jadwalJamMasuk,
    required String jadwalJamPulang,
    required bool sudahAbsenMasuk,
    required bool sudahAbsenPulang,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyJamMasuk, jadwalJamMasuk);
    await prefs.setString(_keyJamPulang, jadwalJamPulang);

    await _cancelAllReminders();

    final masukParts = _parseTime(jadwalJamMasuk);
    final pulangParts = _parseTime(jadwalJamPulang);

    if (masukParts == null || pulangParts == null) return;

    final jakarta = tz.getLocation('Asia/Jakarta');
    final now = tz.TZDateTime.now(jakarta);

    for (int i = 0; i < _daysAhead; i++) {
      final targetDate = now.add(Duration(days: i));
      final isToday = i == 0;

      if (targetDate.weekday == 6 || targetDate.weekday == 7) continue;

      final reminderMasuk = tz.TZDateTime(
        jakarta,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        masukParts[0],
        masukParts[1],
      ).subtract(Duration(minutes: _minutesBefore));

      if (!isToday || (!sudahAbsenMasuk && reminderMasuk.isAfter(now))) {
        if (reminderMasuk.isAfter(now)) {
          await _scheduleNotification(
            id: _baseIdMasuk + i,
            title: '⏰ Pengingat Absen Masuk',
            body: 'Jangan lupa absen masuk! Jadwal masuk: $jadwalJamMasuk',
            scheduledDate: reminderMasuk,
          );
        }
      }

      final reminderPulang = tz.TZDateTime(
        jakarta,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        pulangParts[0],
        pulangParts[1],
      ).subtract(Duration(minutes: _minutesBefore));

      if (!isToday || (!sudahAbsenPulang && reminderPulang.isAfter(now))) {
        if (reminderPulang.isAfter(now)) {
          await _scheduleNotification(
            id: _baseIdPulang + i,
            title: '⏰ Pengingat Absen Pulang',
            body: 'Jangan lupa absen pulang! Jadwal pulang: $jadwalJamPulang',
            scheduledDate: reminderPulang,
          );
        }
      }

      final reminderLupa = tz.TZDateTime(
        jakarta,
        targetDate.year,
        targetDate.month,
        targetDate.day,
        masukParts[0],
        masukParts[1],
      ).add(Duration(minutes: _minutesAfterForLupa));

      if (!isToday || (!sudahAbsenMasuk && reminderLupa.isAfter(now))) {
        if (reminderLupa.isAfter(now)) {
          await _scheduleNotification(
            id: _baseIdLupa + i,
            title: '⚠️ Anda Belum Absen Masuk',
            body:
                'Sudah $_minutesAfterForLupa menit lewat jadwal masuk ($jadwalJamMasuk). Segera lakukan absen!',
            scheduledDate: reminderLupa,
          );
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'attendance_reminder',
      'Pengingat Absen',
      channelDescription: 'Pengingat absen masuk dan pulang otomatis',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> _cancelAllReminders() async {
    for (int i = 0; i < _daysAhead; i++) {
      await _notifications.cancel(id: _baseIdMasuk + i);
      await _notifications.cancel(id: _baseIdPulang + i);
      await _notifications.cancel(id: _baseIdLupa + i);
    }
  }

  Future<void> cancelAll() async {
    await _cancelAllReminders();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyJamMasuk);
    await prefs.remove(_keyJamPulang);
  }

  List<int>? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty || timeStr == '-') return null;
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return null;
      return [int.parse(parts[0]), int.parse(parts[1])];
    } catch (e) {
      return null;
    }
  }
}
