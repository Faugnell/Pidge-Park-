import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../game/daily_challenge_controller.dart';
import '../game/daily_gift_controller.dart';
import '../game/game_controller.dart';

class LocalNotificationService {
  LocalNotificationService({this.useNativePlugin = true});

  static const _arrivalId = 100;
  static const _challengeId = 200;
  static const _giftId = 300;

  final bool useNativePlugin;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<String?> selectedDestination = ValueNotifier(null);
  bool _initialized = false;

  bool get _isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> initialize() async {
    if (_initialized || !useNativePlugin || !_isSupported) return;
    tz_data.initializeTimeZones();
    final deviceTimezone = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } on ArgumentError {
      // The timezone database may not know a rare device alias. UTC is safer
      // than preventing the application from starting.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        _selectDestination(response.payload);
      },
    );
    _initialized = true;
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _selectDestination(launchDetails?.notificationResponse?.payload);
    }
  }

  String? takeSelectedDestination() {
    final destination = selectedDestination.value;
    selectedDestination.value = null;
    return destination;
  }

  @visibleForTesting
  void simulateNotificationTap(String destination) {
    _selectDestination(destination);
  }

  void _selectDestination(String? destination) {
    if (destination == null || destination.isEmpty) return;
    selectedDestination.value = destination;
  }

  void dispose() {
    selectedDestination.dispose();
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (!useNativePlugin || !_isSupported) return true;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  Future<void> synchronize({
    required bool enabled,
    required bool isFrench,
    required GameController game,
    required DailyChallengeController challenge,
    required DailyGiftController gift,
  }) async {
    await initialize();
    if (!useNativePlugin || !_isSupported) return;
    if (!enabled) {
      await cancelAll();
      return;
    }

    await _scheduleArrival(game, isFrench);
    await _scheduleChallenge(challenge, isFrench);
    await _scheduleGift(gift, isFrench);
  }

  Future<void> cancelAll() async {
    if (!_initialized || !useNativePlugin || !_isSupported) return;
    await Future.wait([
      _plugin.cancel(id: _arrivalId),
      _plugin.cancel(id: _challengeId),
      _plugin.cancel(id: _giftId),
    ]);
  }

  Future<void> _scheduleArrival(GameController game, bool isFrench) async {
    await _plugin.cancel(id: _arrivalId);
    final arrival = game.arrivalAt;
    if (arrival == null || !arrival.isAfter(DateTime.now())) return;
    await _schedule(
      id: _arrivalId,
      date: arrival,
      title: isFrench ? 'Un pigeon est arrivé !' : 'A pigeon has arrived!',
      body: isFrench
          ? 'Reviens au parc pour découvrir ton visiteur.'
          : 'Come back to the park to meet your visitor.',
      payload: 'park',
    );
  }

  Future<void> _scheduleChallenge(
    DailyChallengeController challenge,
    bool isFrench,
  ) async {
    await _plugin.cancel(id: _challengeId);
    final now = DateTime.now();
    var reminder = DateTime(now.year, now.month, now.day, 18);
    if (!reminder.isAfter(now) || challenge.completed) {
      reminder = reminder.add(const Duration(days: 1));
    }
    await _schedule(
      id: _challengeId,
      date: reminder,
      title: isFrench ? 'Pigeon du jour' : 'Pigeon of the day',
      body: isFrench
          ? 'Ton défi quotidien t’attend dans le parc.'
          : 'Your daily challenge is waiting in the park.',
      payload: 'daily_challenge',
    );
  }

  Future<void> _scheduleGift(DailyGiftController gift, bool isFrench) async {
    await _plugin.cancel(id: _giftId);
    final now = DateTime.now();
    var reminder = DateTime(now.year, now.month, now.day, 12);
    if (!gift.isAvailable || !reminder.isAfter(now)) {
      reminder = reminder.add(const Duration(days: 1));
    }
    await _schedule(
      id: _giftId,
      date: reminder,
      title: isFrench ? 'Tes miettes sont prêtes' : 'Your crumbs are ready',
      body: isFrench
          ? 'Récupère ton cadeau quotidien de 100 miettes.'
          : 'Claim your daily gift of 100 crumbs.',
      payload: 'daily_gift',
    );
  }

  Future<void> _schedule({
    required int id,
    required DateTime date,
    required String title,
    required String body,
    required String payload,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      scheduledDate: tz.TZDateTime.from(date, tz.local),
      title: title,
      body: body,
      payload: payload,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'pidge_park_reminders',
          'Rappels de Pidge Park',
          channelDescription: 'Arrivées de pigeons et rappels quotidiens',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
