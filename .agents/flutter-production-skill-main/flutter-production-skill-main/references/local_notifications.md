# Notifications — Local, Scheduled & In-App Banners

```yaml
dependencies:
  flutter_local_notifications: ^17.2.2
  timezone: ^0.9.4
```

---

## Full Local Notification Setup

```dart
@lazySingleton
class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Init timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(
      tz.getLocation(await FlutterTimezone.getLocalTimezone()),
    );

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    await _plugin.initialize(
      const InitializationSettings(
          android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    await _createChannels();
  }

  Future<void> _createChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'reminders',
      'Reminders',
      description: 'Reminder notifications',
      importance: Importance.high,
      playSound: true,
    ));

    await android?.createNotificationChannel(const AndroidNotificationChannel(
      'updates',
      'Updates',
      description: 'App update notifications',
      importance: Importance.defaultImportance,
    ));
  }

  // ── Show Immediate ───────────────────────────────────────
  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    String channelId = 'reminders',
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@drawable/ic_notification',
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  // ── Schedule at Exact Time ───────────────────────────────
  Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool repeating = false,
    RepeatInterval? repeatInterval,
  }) async {
    final scheduledTz = tz.TZDateTime.from(scheduledDate, tz.local);

    if (repeating && repeatInterval != null) {
      await _plugin.periodicallyShow(
        id, title, body, repeatInterval,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders', 'Reminders',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } else {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTz,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders', 'Reminders',
            importance: Importance.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  // ── Schedule Daily at Specific Time ─────────────────────
  Future<void> scheduleDailyAt({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      time.hour, time.minute,
    );
    // If time already passed today, schedule for tomorrow
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id, title, body, scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders', 'Reminders',
          importance: Importance.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
      matchDateTimeComponents: DateTimeComponents.time, // repeat daily
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ── Schedule Weekly ──────────────────────────────────────
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required Day day,
    required TimeOfDay time,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);

    while (scheduled.weekday != day.value) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id, title, body, scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails('reminders', 'Reminders'),
        iOS: DarwinNotificationDetails(),
      ),
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // ── Cancel ───────────────────────────────────────────────
  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  // ── Pending ──────────────────────────────────────────────
  Future<List<PendingNotificationRequest>> getPending() =>
      _plugin.pendingNotificationRequests();

  // ── Tap Handlers ─────────────────────────────────────────
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      getIt<AppRouter>().router.go(response.payload!);
    }
  }

  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(NotificationResponse response) {
    // Handle background tap
  }

  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // iOS < 10 only
  }

  // ── Permission ───────────────────────────────────────────
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    return false;
  }
}
```

---

## Medicine Reminder Example (Daily Repeat)

```dart
// Schedule reminder for each medicine
Future<void> scheduleMedicineReminder({
  required int medicineId,
  required String medicineName,
  required TimeOfDay time,
}) async {
  await getIt<LocalNotificationService>().scheduleDailyAt(
    id: medicineId,
    title: '💊 Time for $medicineName',
    body: 'Don\'t forget your medication!',
    time: time,
    payload: '/medicines/$medicineId',
  );
}
```

---

## In-App Notification Banner

```dart
// overlay_support package — OR custom implementation
class InAppBanner extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;

  const InAppBanner({
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.onTap,
    super.key,
  });

  static void show(BuildContext context, {
    required String title,
    String? subtitle,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _AnimatedBanner(
        title: title,
        subtitle: subtitle,
        icon: icon,
        onTap: onTap,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
    // Auto-dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (entry.mounted) entry.remove();
    });
  }
}

class _AnimatedBanner extends StatefulWidget { ... }
class _AnimatedBannerState extends State<_AnimatedBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 16, right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                if (widget.icon != null)
                  Icon(widget.icon, size: 28),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (widget.subtitle != null)
                      Text(widget.subtitle!, style: const TextStyle(fontSize: 12)),
                  ],
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Notification Preferences

```dart
// Let users control which notifications they receive
class NotificationPreferences {
  final bool reminders;
  final bool promotions;
  final bool updates;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  const NotificationPreferences({
    this.reminders = true,
    this.promotions = false,
    this.updates = true,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  bool get hasQuietHours =>
      quietHoursStart != null && quietHoursEnd != null;

  bool isQuietNow() {
    if (!hasQuietHours) return false;
    final now = TimeOfDay.now();
    // Simple range check (ignores midnight crossing for brevity)
    return now.hour >= quietHoursStart!.hour &&
           now.hour < quietHoursEnd!.hour;
  }
}
```
