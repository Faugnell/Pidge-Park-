import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import 'daily_cycle.dart';

enum FriendshipActivity {
  play('Jouer', 'Play', Duration(minutes: 10), Duration(seconds: 8), 3),
  pet('Caresser', 'Pet', Duration(minutes: 5), Duration(seconds: 6), 2),
  photo(
    'Prendre en photo',
    'Take a photo',
    Duration(minutes: 20),
    Duration(seconds: 10),
    4,
  ),
  music(
    'Écouter de la musique',
    'Listen to music',
    Duration(minutes: 30),
    Duration(seconds: 12),
    5,
  );

  const FriendshipActivity(
    this.nameFr,
    this.nameEn,
    this.duration,
    this.debugDuration,
    this.points,
  );

  final String nameFr;
  final String nameEn;
  final Duration duration;
  final Duration debugDuration;
  final int points;

  String label(bool isFrench) => isFrench ? nameFr : nameEn;
}

class FriendshipActivityController extends ChangeNotifier {
  FriendshipActivityController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
    bool? useFastTimers,
    DateTime Function()? now,
    this.cycle = const DailyCycle(),
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null,
       useFastTimers = useFastTimers ?? kDebugMode,
       _now = now ?? DateTime.now;

  static const _pigeonKey = 'friendship_activity.pigeon';
  static const _activityKey = 'friendship_activity.type';
  static const _completionKey = 'friendship_activity.completes_at';
  static const _startedDayKey = 'friendship_activity.started_day';

  final SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final DailyCycle cycle;
  final bool useFastTimers;
  final Map<String, String> _lastInteractionDays = {};
  final Map<String, int> _completedInteractionCounts = {};

  String? activePigeonId;
  FriendshipActivity? activeActivity;
  DateTime? completesAt;
  String? startedDay;

  bool get hasActiveActivity =>
      activePigeonId != null && activeActivity != null && completesAt != null;
  bool get isComplete => hasActiveActivity && !completesAt!.isAfter(_now());
  Duration get remaining => !hasActiveActivity || isComplete
      ? Duration.zero
      : completesAt!.difference(_now());

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) return;
    activePigeonId = await preferences.getString(_pigeonKey);
    final activityName = await preferences.getString(_activityKey);
    activeActivity = FriendshipActivity.values
        .where((activity) => activity.name == activityName)
        .firstOrNull;
    final savedCompletion = await preferences.getString(_completionKey);
    completesAt = savedCompletion == null
        ? null
        : DateTime.tryParse(savedCompletion);
    startedDay = await preferences.getString(_startedDayKey);
    for (final pigeon in pigeons) {
      final day = await preferences.getString(_lastDayKey(pigeon.id));
      if (day != null) _lastInteractionDays[pigeon.id] = day;
      final count = await preferences.getInt(_completionCountKey(pigeon.id));
      if (count != null) _completedInteractionCounts[pigeon.id] = count;
    }
    if (!hasActiveActivity) await _clearActive();
    notifyListeners();
  }

  bool canInteractWith(String pigeonId) =>
      _lastInteractionDays[pigeonId] != cycle.keyFor(_now());

  FriendshipActivity favoriteActivityFor(String pigeonId) {
    final pigeon = pigeons.firstWhere((item) => item.id == pigeonId);
    return FriendshipActivity.values[(pigeon.number - 1) %
        FriendshipActivity.values.length];
  }

  int completedInteractionsFor(String pigeonId) =>
      _completedInteractionCounts[pigeonId] ?? 0;

  bool isFavoriteActivity(String pigeonId, FriendshipActivity activity) =>
      favoriteActivityFor(pigeonId) == activity;

  Future<bool> start(String pigeonId, FriendshipActivity activity) async {
    if (hasActiveActivity || !canInteractWith(pigeonId)) return false;
    activePigeonId = pigeonId;
    activeActivity = activity;
    startedDay = cycle.keyFor(_now());
    completesAt = _now().add(
      useFastTimers ? activity.debugDuration : activity.duration,
    );
    notifyListeners();
    await _saveActive();
    return true;
  }

  Future<int?> claim(PigeonCollectionController collection) async {
    final pigeonId = activePigeonId;
    final activity = activeActivity;
    if (!isComplete || pigeonId == null || activity == null) return null;
    final points =
        activity.points + (isFavoriteActivity(pigeonId, activity) ? 2 : 0);
    await collection.addFriendshipPoints(pigeonId, points);
    final interactionDay = startedDay ?? cycle.keyFor(_now());
    _lastInteractionDays[pigeonId] = interactionDay;
    final completionCount = completedInteractionsFor(pigeonId) + 1;
    _completedInteractionCounts[pigeonId] = completionCount;
    await Future.wait([
      if (_preferences != null)
        _preferences.setString(_lastDayKey(pigeonId), interactionDay),
      if (_preferences != null)
        _preferences.setInt(_completionCountKey(pigeonId), completionCount),
    ]);
    await _clearActive();
    notifyListeners();
    return points;
  }

  Future<void> resetAllData() async {
    final preferences = _preferences;
    await _clearActive();
    for (final pigeon in pigeons) {
      await preferences?.remove(_lastDayKey(pigeon.id));
      await preferences?.remove(_completionCountKey(pigeon.id));
    }
    _lastInteractionDays.clear();
    _completedInteractionCounts.clear();
    notifyListeners();
  }

  String _lastDayKey(String pigeonId) =>
      'friendship_activity.last_day.$pigeonId';

  String _completionCountKey(String pigeonId) =>
      'friendship_activity.completed_count.$pigeonId';

  Future<void> _saveActive() async {
    final preferences = _preferences;
    if (preferences == null) return;
    await Future.wait([
      preferences.setString(_pigeonKey, activePigeonId!),
      preferences.setString(_activityKey, activeActivity!.name),
      preferences.setString(_completionKey, completesAt!.toIso8601String()),
      preferences.setString(_startedDayKey, startedDay!),
    ]);
  }

  Future<void> _clearActive() async {
    activePigeonId = null;
    activeActivity = null;
    completesAt = null;
    startedDay = null;
    final preferences = _preferences;
    if (preferences == null) return;
    await Future.wait([
      preferences.remove(_pigeonKey),
      preferences.remove(_activityKey),
      preferences.remove(_completionKey),
      preferences.remove(_startedDayKey),
    ]);
  }
}
