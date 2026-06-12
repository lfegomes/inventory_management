import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> scheduleExpiryNotifications({
    required int productId,
    required String productName,
    required DateTime expiryDate,
  }) async {
    await _scheduleNotification(
      id: _notificationId(productId, 20),
      title: 'Produto próximo do vencimento',
      body: '$productName vence em 20 dias.',
      scheduledDate: expiryDate.subtract(const Duration(days: 20)),
    );

    await _scheduleNotification(
      id: _notificationId(productId, 10),
      title: 'Produto próximo do vencimento',
      body: '$productName vence em 10 dias.',
      scheduledDate: expiryDate.subtract(const Duration(days: 10)),
    );
  }

  Future<void> cancelExpiryNotifications(int productId) async {
    await _plugin.cancel(_notificationId(productId, 20));
    await _plugin.cancel(_notificationId(productId, 10));
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final scheduleAt = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      10,
      0,
      0,
    );

    final now = DateTime.now();
    if (scheduleAt.isBefore(now)) return;

    final tzSchedule = tz.TZDateTime.from(scheduleAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'expiry_channel',
      'Vencimento de produtos',
      channelDescription: 'Alertas de validade de produtos do estoque',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzSchedule,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  int _notificationId(int productId, int daysBefore) {
    return productId * 100 + daysBefore;
  }
}
