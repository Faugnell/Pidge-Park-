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

enum DailyMissionType { feedPark, friendshipInteraction, welcomePigeons }

class DailyMission {
  const DailyMission({
    required this.type,
    required this.target,
    required this.crumbReward,
    required this.featherReward,
  });

  final DailyMissionType type;
  final int target;
  final int crumbReward;
  final int featherReward;
}

const dailyMissions = <DailyMission>[
  DailyMission(
    type: DailyMissionType.feedPark,
    target: 1,
    crumbReward: 50,
    featherReward: 0,
  ),
  DailyMission(
    type: DailyMissionType.friendshipInteraction,
    target: 1,
    crumbReward: 0,
    featherReward: 3,
  ),
  DailyMission(
    type: DailyMissionType.welcomePigeons,
    target: 3,
    crumbReward: 75,
    featherReward: 0,
  ),
];

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
  static const _missionProgressKey = 'daily.missions.progress';
  static const _missionClaimsKey = 'daily.missions.claimed';
  static const _missionChestKey = 'daily.missions.chest';
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
  final Map<DailyMissionType, int> _missionProgress = {};
  final Set<DailyMissionType> _claimedMissions = {};
  bool missionChestClaimed = false;

  int missionProgress(DailyMission mission) =>
      (_missionProgress[mission.type] ?? 0).clamp(0, mission.target);
  bool isMissionComplete(DailyMission mission) =>
      missionProgress(mission) >= mission.target;
  bool isMissionClaimed(DailyMission mission) =>
      _claimedMissions.contains(mission.type);
  bool get canClaimMissionChest =>
      !missionChestClaimed && dailyMissions.every(isMissionClaimed);
  bool get allDailyGoalsClaimed => completed && missionChestClaimed;

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
    final savedProgress =
        await preferences?.getStringList(_missionProgressKey) ?? const [];
    for (final entry in savedProgress) {
      final parts = entry.split(':');
      final type = DailyMissionType.values
          .where((item) => item.name == parts.firstOrNull)
          .firstOrNull;
      final value = parts.length > 1 ? int.tryParse(parts[1]) : null;
      if (type != null && value != null) _missionProgress[type] = value;
    }
    final savedClaims =
        await preferences?.getStringList(_missionClaimsKey) ?? const [];
    _claimedMissions.addAll(
      DailyMissionType.values.where((item) => savedClaims.contains(item.name)),
    );
    missionChestClaimed = await preferences?.getBool(_missionChestKey) ?? false;
    await refreshDay();
  }

  Future<void> refreshDay() async {
    final today = cycle.keyFor(_now());
    if (challengeDate == today) return;
    challengeDate = today;
    completed = false;
    _missionProgress.clear();
    _claimedMissions.clear();
    missionChestClaimed = false;
    notifyListeners();
    await _save();
  }

  Future<void> recordParkFed() =>
      _recordMissionProgress(DailyMissionType.feedPark, 1);

  Future<void> recordFriendshipInteraction() =>
      _recordMissionProgress(DailyMissionType.friendshipInteraction, 1);

  Future<void> recordWelcomedPigeons(int count) =>
      _recordMissionProgress(DailyMissionType.welcomePigeons, count);

  Future<void> _recordMissionProgress(DailyMissionType type, int amount) async {
    await refreshDay();
    if (amount <= 0) return;
    final mission = dailyMissions.firstWhere((item) => item.type == type);
    _missionProgress[type] = ((_missionProgress[type] ?? 0) + amount).clamp(
      0,
      mission.target,
    );
    notifyListeners();
    await _save();
  }

  Future<bool> claimMission(
    DailyMission mission,
    GameController gameController,
  ) async {
    await refreshDay();
    if (!isMissionComplete(mission) || isMissionClaimed(mission)) return false;
    _claimedMissions.add(mission.type);
    await gameController.addReward(
      crumbs: mission.crumbReward,
      feathers: mission.featherReward,
    );
    notifyListeners();
    await _save();
    return true;
  }

  Future<bool> claimMissionChest(GameController gameController) async {
    await refreshDay();
    if (!canClaimMissionChest) return false;
    missionChestClaimed = true;
    await gameController.addReward(crumbs: 150, feathers: 5);
    notifyListeners();
    await _save();
    return true;
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
    await preferences?.remove(_missionProgressKey);
    await preferences?.remove(_missionClaimsKey);
    await preferences?.remove(_missionChestKey);
    challengeDate = cycle.keyFor(_now());
    completed = false;
    streak = 0;
    lastCompletedDate = null;
    _missionProgress.clear();
    _claimedMissions.clear();
    missionChestClaimed = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences?.setString(_dateKey, challengeDate);
    await _preferences?.setBool(_completedKey, completed);
    await _preferences?.setInt(_streakKey, streak);
    await _preferences?.setStringList(
      _missionProgressKey,
      _missionProgress.entries
          .map((entry) => '${entry.key.name}:${entry.value}')
          .toList(),
    );
    await _preferences?.setStringList(
      _missionClaimsKey,
      _claimedMissions.map((item) => item.name).toList(),
    );
    await _preferences?.setBool(_missionChestKey, missionChestClaimed);
  }
}
