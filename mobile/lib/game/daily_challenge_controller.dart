import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pigeon.dart';
import 'daily_cycle.dart';
import 'game_controller.dart';

class DailyReward {
  const DailyReward({required this.crumbs, required this.feathers});
  final int crumbs;
  final int feathers;
}

class DailyChallengeController extends ChangeNotifier {
  DailyChallengeController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
    DateTime Function()? now,
    this.cycle = const DailyCycle(),
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null,
       _now = now ?? DateTime.now;

  static const _dateKey = 'daily.date';
  static const _completedKey = 'daily.completed';
  static const _streakKey = 'daily.streak';
  static const _lastCompletedKey = 'daily.last_completed';
  static const _dailyTargetIds = <String>[
    'kevin',
    'brenda',
    'jean_pigeon',
    'croissigeon',
    'pigeoffrey',
    'gothigeon',
    'disco_pigeon',
    'pigeasso',
    'sherlock',
    'chonky',
  ];

  final SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final DailyCycle cycle;

  String challengeDate = '';
  bool completed = false;
  int streak = 0;
  String? lastCompletedDate;

  String get targetId {
    final date = cycle.startFor(_now());
    final dayNumber = date.difference(DateTime(2026)).inDays;
    return _dailyTargetIds[dayNumber.abs() % _dailyTargetIds.length];
  }

  Pigeon get target => pigeons.firstWhere((pigeon) => pigeon.id == targetId);

  Future<void> load() async {
    final preferences = _preferences;
    challengeDate = await preferences?.getString(_dateKey) ?? '';
    completed = await preferences?.getBool(_completedKey) ?? false;
    streak = await preferences?.getInt(_streakKey) ?? 0;
    lastCompletedDate = await preferences?.getString(_lastCompletedKey);
    await refreshDay();
  }

  Future<void> refreshDay() async {
    final today = cycle.keyFor(_now());
    if (challengeDate == today) return;
    challengeDate = today;
    completed = false;
    notifyListeners();
    await _save();
  }

  Future<DailyReward?> recordEncounter(
    String pigeonId,
    GameController gameController,
  ) async {
    await refreshDay();
    if (completed || pigeonId != targetId) return null;

    final yesterday = cycle.keyFor(
      cycle.startFor(_now()).subtract(const Duration(hours: 1)),
    );
    streak = lastCompletedDate == yesterday ? streak + 1 : 1;
    completed = true;
    final featherReward = streak % 7 == 0 ? 5 : 0;
    await gameController.addReward(crumbs: 250, feathers: featherReward);
    notifyListeners();
    lastCompletedDate = challengeDate;
    await _preferences?.setString(_lastCompletedKey, challengeDate);
    await _save();
    return DailyReward(crumbs: 250, feathers: featherReward);
  }

  Future<void> resetAllData() async {
    final preferences = _preferences;
    await preferences?.remove(_dateKey);
    await preferences?.remove(_completedKey);
    await preferences?.remove(_streakKey);
    await preferences?.remove(_lastCompletedKey);
    challengeDate = cycle.keyFor(_now());
    completed = false;
    streak = 0;
    lastCompletedDate = null;
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences?.setString(_dateKey, challengeDate);
    await _preferences?.setBool(_completedKey, completed);
    await _preferences?.setInt(_streakKey, streak);
  }
}
