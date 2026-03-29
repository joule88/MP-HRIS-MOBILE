import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/notification_provider.dart';
import '../repositories/notifikasi_repository.dart';
import '../main.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotifikasiRepository _repository = NotifikasiRepository();

  bool _initialized = false;

  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;
    _initialized = true;

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token != null) await _repository.saveDeviceToken(token);

    _messaging.onTokenRefresh.listen((t) => _repository.saveDeviceToken(t));

    FirebaseMessaging.onMessage.listen((msg) {
      if (context.mounted) {
        _showBanner(context, msg);
        context.read<NotificationProvider>().fetchUnreadCount();
      }
      _showSystemNotification(msg);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      _navigateToNotification();
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      Future.delayed(const Duration(seconds: 1), () {
        _navigateToNotification();
      });
    }
  }

  void _onNotificationTap(NotificationResponse details) {
    _navigateToNotification();
  }

  void _navigateToNotification() {
    final nav = navigatorKey.currentState;
    if (nav != null) {
      nav.pushNamedAndRemoveUntil('/home', (route) => false);
      nav.pushNamed('/notification');
    }
  }

  IconData _iconForTipe(String? tipe) {
    if (tipe == null) return Icons.notifications_outlined;
    if (tipe.contains('disetujui')) return Icons.check_circle_rounded;
    if (tipe.contains('ditolak')) return Icons.cancel_rounded;
    if (tipe.contains('pengumuman')) return Icons.campaign_rounded;
    if (tipe.contains('lembur')) return Icons.schedule_rounded;
    if (tipe.contains('presensi')) return Icons.fingerprint_rounded;
    if (tipe.contains('izin')) return Icons.description_rounded;
    if (tipe.contains('poin')) return Icons.stars_rounded;
    return Icons.notifications_outlined;
  }

  Color _colorForTipe(String? tipe) {
    if (tipe == null) return AppTheme.primaryBlue;
    if (tipe.contains('disetujui')) return const Color(0xFF10b981);
    if (tipe.contains('ditolak')) return const Color(0xFFef4444);
    if (tipe.contains('pengumuman')) return AppTheme.primaryBlue;
    if (tipe.contains('lembur')) return const Color(0xFFf59e0b);
    if (tipe.contains('poin')) return const Color(0xFFe11d48);
    return const Color(0xFF6366f1);
  }

  void _showBanner(BuildContext context, RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final tipe = message.data['tipe'] as String?;
    final color = _colorForTipe(tipe);
    final icon = _iconForTipe(tipe);

    if (title.isEmpty) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _NotificationBanner(
        title: title,
        body: body,
        icon: icon,
        color: color,
        onTap: () {
          entry.remove();
          _navigateToNotification();
        },
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 5), () {
      if (entry.mounted) entry.remove();
    });
  }

  Future<void> _showSystemNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    if (title.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      'hris_channel',
      'HRIS Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'notification',
    );
  }
}

class _NotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 12,
      right: 12,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
                _controller.reverse().then((_) => widget.onDismiss());
              }
            },
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: widget.color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1e293b),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF64748b),
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Lihat',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: widget.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
