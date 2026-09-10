import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PigeonProgress {
  const PigeonProgress({
    required this.discovered,
    required this.friendshipPoints,
    required this.visits,
  });

  static const levelThresholds = <int>[0, 3, 7, 12, 19, 28, 40, 55, 74, 98];

  final bool discovered;
  final int friendshipPoints;
  final int visits;

  int get affection {
    var level = 1;
    for (var index = 0; index < levelThresholds.length; index++) {
      if (friendshipPoints >= levelThresholds[index]) level = index + 1;
    }
    return level;
  }

  bool get isMaxFriendship => affection >= levelThresholds.length;
  int? get nextLevelThreshold =>
      isMaxFriendship ? null : levelThresholds[affection];
  int get currentLevelThreshold => levelThresholds[affection - 1];
  int get pointsIntoLevel => friendshipPoints - currentLevelThreshold;
  int get pointsRequiredForNextLevel => nextLevelThreshold == null
      ? 0
      : nextLevelThreshold! - currentLevelThreshold;
  int get pointsUntilNextLevel =>
      nextLevelThreshold == null ? 0 : nextLevelThreshold! - friendshipPoints;
  double get levelProgress =>
      isMaxFriendship ? 1 : pointsIntoLevel / pointsRequiredForNextLevel;

  PigeonProgress copyWith({
    bool? discovered,
    int? friendshipPoints,
    int? visits,
  }) {
    return PigeonProgress(
      discovered: discovered ?? this.discovered,
      friendshipPoints: friendshipPoints ?? this.friendshipPoints,
      visits: visits ?? this.visits,
    );
  }

  static int pointsForLevel(int level) {
    final safeLevel = level.clamp(1, levelThresholds.length);
    return levelThresholds[safeLevel - 1];
  }
}

class PigeonCollectionController extends ChangeNotifier {
  PigeonCollectionController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null;

  static const _discoveredKey = 'pigeons.discovered';
  static const _defaultDiscovered = <String>{'gilbert'};

  final SharedPreferencesAsync? _preferences;
  final Map<String, PigeonProgress> _progress = {};
  final Map<String, Set<int>> _claimedFriendshipMilestones = {};

  static const friendshipMilestoneLevels = <int>[2, 4, 6, 10];

  PigeonProgress progressFor(String id) {
    return _progress[id] ??
        PigeonProgress(
          discovered: _defaultDiscovered.contains(id),
          friendshipPoints: id == 'gilbert'
              ? PigeonProgress.pointsForLevel(7)
              : 0,
          visits: id == 'gilbert' ? 4 : 1,
        );
  }

  int get discoveredCount =>
      _progress.values.where((progress) => progress.discovered).length;

  Future<void> load() async {
    final preferences = _preferences;
    final discovered = preferences == null
        ? _defaultDiscovered
        : (await preferences.getStringList(_discoveredKey))?.toSet() ??
              _defaultDiscovered;

    for (final id in {..._defaultDiscovered, ...discovered}) {
      final defaultProgress = progressFor(id);
      final savedPoints = await preferences?.getInt(
        'pigeon.$id.friendship_points',
      );
      final legacyAffection = await preferences?.getInt('pigeon.$id.affection');
      _progress[id] = PigeonProgress(
        discovered: discovered.contains(id),
        friendshipPoints:
            savedPoints ??
            (legacyAffection == null
                ? defaultProgress.friendshipPoints
                : PigeonProgress.pointsForLevel(legacyAffection)),
        visits:
            await preferences?.getInt('pigeon.$id.visits') ??
            defaultProgress.visits,
      );
      _claimedFriendshipMilestones[id] =
          (await preferences?.getStringList(_milestonesKey(id)))
              ?.map(int.tryParse)
              .whereType<int>()
              .toSet() ??
          <int>{};
    }
    notifyListeners();
  }

  Future<bool> giveFood(String id, {int points = 3}) async {
    return addFriendshipPoints(id, points);
  }

  Future<bool> addFriendshipPoints(String id, int points) async {
    final current = progressFor(id);
    if (!current.discovered || current.isMaxFriendship || points <= 0) {
      return false;
    }

    final updated = current.copyWith(
      friendshipPoints: (current.friendshipPoints + points).clamp(
        0,
        PigeonProgress.levelThresholds.last,
      ),
    );
    _progress[id] = updated;
    notifyListeners();
    await _preferences?.setInt(
      'pigeon.$id.friendship_points',
      updated.friendshipPoints,
    );
    return true;
  }

  Future<bool> recordVisit(String id) async {
    final current = progressFor(id);
    final isNew = !current.discovered;
    final updated = current.copyWith(
      discovered: true,
      visits: current.visits + 1,
      friendshipPoints: (current.friendshipPoints + 1).clamp(
        0,
        PigeonProgress.levelThresholds.last,
      ),
    );
    _progress[id] = updated;
    notifyListeners();

    await _preferences?.setInt(
      'pigeon.$id.friendship_points',
      updated.friendshipPoints,
    );
    await _preferences?.setInt('pigeon.$id.visits', updated.visits);
    await _saveDiscovered();
    return isNew;
  }

  Future<void> discover(String id) async {
    final current = progressFor(id);
    _progress[id] = current.copyWith(discovered: true, visits: 1);
    notifyListeners();
    await _saveDiscovered();
  }

  bool hasClaimedFriendshipMilestone(String id, int level) =>
      _claimedFriendshipMilestones[id]?.contains(level) ?? false;

  bool canClaimFriendshipMilestone(String id, int level) =>
      friendshipMilestoneLevels.contains(level) &&
      progressFor(id).affection >= level &&
      !hasClaimedFriendshipMilestone(id, level);

  Future<bool> claimFriendshipMilestone(String id, int level) async {
    if (!canClaimFriendshipMilestone(id, level)) return false;
    final claimed = _claimedFriendshipMilestones.putIfAbsent(id, () => {});
    claimed.add(level);
    notifyListeners();
    await _preferences?.setStringList(
      _milestonesKey(id),
      claimed.map((item) => '$item').toList()..sort(),
    );
    return true;
  }

  Future<void> resetAllData() async {
    final preferences = _preferences;
    if (preferences != null) {
      await preferences.remove(_discoveredKey);
      for (final id in _progress.keys) {
        await preferences.remove('pigeon.$id.affection');
        await preferences.remove('pigeon.$id.friendship_points');
        await preferences.remove('pigeon.$id.visits');
        await preferences.remove(_milestonesKey(id));
      }
    }
    _progress.clear();
    _claimedFriendshipMilestones.clear();
    await load();
  }

  String _milestonesKey(String id) => 'pigeon.$id.friendship_milestones';

  Future<void> _saveDiscovered() async {
    final discovered = _progress.entries
        .where((entry) => entry.value.discovered)
        .map((entry) => entry.key)
        .toList();
    await _preferences?.setStringList(_discoveredKey, discovered);
  }
}
