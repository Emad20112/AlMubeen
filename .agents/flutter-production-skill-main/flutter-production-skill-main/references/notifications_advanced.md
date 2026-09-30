# Notifications Advanced — Actions, Background Handling & Strategies

## Notification Action Buttons

```dart
// Create notification with action buttons
Future<void> showNotificationWithActions({
  required int id,
  required String title,
  required String body,
  required String payload,
}) async {
  const androidDetails = AndroidNotificationDetails(
    'reminders',
    'Reminders',
    importance: Importance.high,
    priority: Priority.high,
    actions: [
      AndroidNotificationAction(
        'mark_done',           // action ID
        'Mark Done',           // button label
        cancelNotification: true,
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        'snooze',
        'Snooze 10 min',
        cancelNotification: false,
        showsUserInterface: false,
      ),
    ],
  );

  const iosDetails = DarwinNotificationDetails(
    categoryIdentifier: 'REMINDER_CATEGORY',
  );

  await _plugin.show(
    id, title, body,
    const NotificationDetails(android: androidDetails, iOS: iosDetails),
    payload: payload,
  );
}

// iOS — register notification categories with actions
Future<void> _registerIOSCategories() async {
  await _plugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: false,
        provisional: false,
      );

  // Define iOS category
  const darwinNotificationCategory = DarwinNotificationCategory(
    'REMINDER_CATEGORY',
    actions: [
      DarwinNotificationAction.plain('mark_done', 'Mark Done',
          options: {DarwinNotificationActionOption.foreground}),
      DarwinNotificationAction.plain('snooze', 'Snooze 10 min'),
    ],
    options: {DarwinNotificationCategoryOption.hiddenPreviewShowTitle},
  );

  await _plugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.initialize(
        const IOSInitializationSettings(
          notificationCategories: [darwinNotificationCategory],
        ),
      );
}

// Handle action tap
void _onNotificationTapped(NotificationResponse response) {
  switch (response.actionId) {
    case 'mark_done':
      _handleMarkDone(response.payload);
    case 'snooze':
      _handleSnooze(response.payload);
    case null:
      // Notification body tapped — navigate
      if (response.payload != null) {
        getIt<AppRouter>().router.go(response.payload!);
      }
  }
}

void _handleMarkDone(String? payload) {
  if (payload == null) return;
  final id = int.tryParse(payload);
  if (id != null) {
    getIt<MedicineRepository>().markTaken(id);
  }
}

void _handleSnooze(String? payload) {
  if (payload == null) return;
  final id = int.tryParse(payload);
  if (id == null) return;
  // Reschedule 10 minutes from now
  getIt<LocalNotificationService>().scheduleAt(
    id: id + 1000, // different ID to avoid conflict
    title: 'Reminder (Snoozed)',
    body: 'You snoozed this reminder',
    scheduledDate: DateTime.now().add(const Duration(minutes: 10)),
    payload: payload,
  );
}
```

---

## Background FCM Handler

```dart
// This function must be top-level (not inside a class)
// It runs in a SEPARATE isolate when app is terminated/background
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Must initialize Firebase again — separate isolate
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final data = message.data;
  final type = data['type'] as String?;

  switch (type) {
    case 'medicine_reminder':
      // Can do local storage operations — no UI
      await _markReminderDelivered(data['medicine_id']);
    case 'subscription_update':
      await _syncSubscriptionStatus();
    case 'force_update':
      // Store flag — show dialog when app opens
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('force_update_required', true);
  }
}

// Register in main.dart:
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

---

## Notification Grouping (Android)

```dart
Future<void> showGroupedNotifications(List<String> messages) async {
  const groupKey = 'com.yourapp.MESSAGES';

  // Show individual notifications
  for (int i = 0; i < messages.length; i++) {
    await _plugin.show(
      i,
      'New Message',
      messages[i],
      NotificationDetails(
        android: AndroidNotificationDetails(
          'messages', 'Messages',
          groupKey: groupKey,
          setAsGroupSummary: false,
        ),
      ),
    );
  }

  // Show group summary
  await _plugin.show(
    999,
    '${messages.length} new messages',
    messages.take(3).join(', '),
    NotificationDetails(
      android: AndroidNotificationDetails(
        'messages', 'Messages',
        groupKey: groupKey,
        setAsGroupSummary: true,    // ← this is the summary
        styleInformation: InboxStyleInformation(
          messages,
          contentTitle: '${messages.length} new messages',
          summaryText: 'messages',
        ),
      ),
    ),
  );
}
```

---

## Big Picture / Rich Notifications

```dart
// Show notification with large image
Future<void> showImageNotification({
  required String title,
  required String body,
  required String imageUrl,
}) async {
  // Download image to temp file first
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/notif_image.jpg');
  await Dio().download(imageUrl, file.path);

  await _plugin.show(
    0, title, body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'updates', 'Updates',
        styleInformation: BigPictureStyleInformation(
          FilePathAndroidBitmap(file.path),
          largeIcon: FilePathAndroidBitmap(file.path),
          contentTitle: title,
          summaryText: body,
        ),
      ),
    ),
  );
}
```

---

## Notification Permission Flow (Android 13+)

```dart
// Android 13+ requires explicit notification permission
Future<void> requestNotificationPermission(BuildContext context) async {
  if (!Platform.isAndroid) return;

  // Check SDK version
  final sdkVersion = await DeviceInfoPlugin()
      .androidInfo.then((i) => i.version.sdkInt);
  if (sdkVersion < 33) return; // Android 13+ only

  final status = await Permission.notification.status;
  if (status.isGranted) return;

  if (status.isPermanentlyDenied) {
    // Show dialog explaining why, then open settings
    final openSettings = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Enable Notifications'),
        content: const Text(
            'Allow notifications to receive reminders and important updates.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not Now')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings')),
        ],
      ),
    );
    if (openSettings == true) await openAppSettings();
    return;
  }

  await Permission.notification.request();
}
```

---

## Notification Strategy by App Type

| App Type | Best Triggers | Avoid |
|----------|--------------|-------|
| **VPN** | Connection drops, session expiry, new server regions | Every reconnect |
| **Medicine** | Daily scheduled, missed dose follow-up | Multiple per day per medicine |
| **Social** | Mentions, DMs, new followers | Every post from every connection |
| **E-commerce** | Order status, delivery, flash sales (max 1/day) | Cart abandonment > 1x, generic promos |
| **Fitness** | Workout reminders, streak alerts, goal achieved | Daily check-ins if no app usage |
