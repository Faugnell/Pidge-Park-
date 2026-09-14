import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/pigeon.dart';
import '../models/pigeon_keepsake.dart';

class KeepsakeDrop {
  const KeepsakeDrop({
    required this.keepsake,
    required this.isDuplicate,
    required this.featherReward,
  });

  final PigeonKeepsake keepsake;
  final bool isDuplicate;
  final int featherReward;
}

class CollectionGoal {
  const CollectionGoal({
    required this.id,
    required this.requiredCount,
    required this.crumbs,
    required this.feathers,
    this.rarity,
    this.decorationId,
    this.completionReward = false,
  });

  final String id;
  final int requiredCount;
  final int crumbs;
  final int feathers;
  final PigeonRarity? rarity;
  final String? decorationId;
  final bool completionReward;
}

const collectionGoals = <CollectionGoal>[
  CollectionGoal(id: 'total.5', requiredCount: 5, crumbs: 250, feathers: 2),
  CollectionGoal(id: 'total.10', requiredCount: 10, crumbs: 500, feathers: 5),
  CollectionGoal(
    id: 'total.15',
    requiredCount: 15,
    crumbs: 800,
    feathers: 8,
    decorationId: 'pigeondex_banner',
  ),
  CollectionGoal(id: 'total.20', requiredCount: 20, crumbs: 1200, feathers: 12),
  CollectionGoal(id: 'total.25', requiredCount: 25, crumbs: 1800, feathers: 18),
  CollectionGoal(
    id: 'total.30',
    requiredCount: 30,
    crumbs: 3000,
    feathers: 30,
    completionReward: true,
  ),
  CollectionGoal(
    id: 'rarity.common',
    requiredCount: 0,
    crumbs: 300,
    feathers: 3,
    rarity: PigeonRarity.common,
  ),
  CollectionGoal(
    id: 'rarity.rare',
    requiredCount: 0,
    crumbs: 600,
    feathers: 6,
    rarity: PigeonRarity.rare,
  ),
  CollectionGoal(
    id: 'rarity.epic',
    requiredCount: 0,
    crumbs: 1000,
    feathers: 10,
    rarity: PigeonRarity.epic,
  ),
  CollectionGoal(
    id: 'rarity.legendary',
    requiredCount: 0,
    crumbs: 2000,
    feathers: 20,
    rarity: PigeonRarity.legendary,
  ),
];

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
    Random? random,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null,
       _random = random ?? Random();

  static const _discoveredKey = 'pigeons.discovered';
  static const _newKey = 'pigeons.new';
  static const _collectionGoalsKey = 'pigeons.collection_goals';
  static const _keepsakesKey = 'pigeons.keepsakes';
  static const _equippedAccessoriesKey = 'pigeons.equipped_accessories';
  static const _equippedCompanionsKey = 'pigeons.equipped_companions';
  static const _equipmentTutorialKey = 'pigeons.equipment_tutorial_seen';
  static const _souvenirTutorialKey = 'pigeons.souvenir_tutorial_seen';
  static const _defaultDiscovered = <String>{'gilbert'};

  final SharedPreferencesAsync? _preferences;
  final Random _random;
  final Map<String, PigeonProgress> _progress = {};
  final Map<String, Set<int>> _claimedFriendshipMilestones = {};
  Set<String> _newPigeonIds = {};
  Set<String> _claimedCollectionGoalIds = {};
  Set<String> _ownedKeepsakeIds = {};
  final Map<String, int> _keepsakeAttempts = {};
  final Map<String, String> _equippedAccessories = {};
  final Map<String, String> _equippedCompanions = {};
  bool equipmentTutorialSeen = false;
  bool souvenirTutorialSeen = false;

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

  Set<String> get newPigeonIds => Set.unmodifiable(_newPigeonIds);
  int get newPigeonCount => _newPigeonIds.length;
  Set<String> get ownedKeepsakeIds => Set.unmodifiable(_ownedKeepsakeIds);
  bool ownsKeepsake(String id) => _ownedKeepsakeIds.contains(id);
  String? equippedAccessoryId(String pigeonId) =>
      _equippedAccessories[pigeonId];
  String? equippedCompanionId(String pigeonId) => _equippedCompanions[pigeonId];
  List<String> pigeonsUsingKeepsake(String keepsakeId) =>
      [..._equippedAccessories.entries, ..._equippedCompanions.entries]
          .where((entry) => entry.value == keepsakeId)
          .map((entry) => entry.key)
          .toList();
  int get discoveredCount =>
      pigeons.where((pigeon) => progressFor(pigeon.id).discovered).length;

  int progressForGoal(CollectionGoal goal) => pigeons
      .where(
        (pigeon) =>
            (goal.rarity == null || pigeon.rarity == goal.rarity) &&
            progressFor(pigeon.id).discovered,
      )
      .length;

  int targetForGoal(CollectionGoal goal) => goal.rarity == null
      ? goal.requiredCount
      : pigeons.where((pigeon) => pigeon.rarity == goal.rarity).length;

  bool isCollectionGoalClaimed(String id) =>
      _claimedCollectionGoalIds.contains(id);

  bool canClaimCollectionGoal(CollectionGoal goal) =>
      progressForGoal(goal) >= targetForGoal(goal) &&
      !isCollectionGoalClaimed(goal.id);

  Future<void> load() async {
    final preferences = _preferences;
    final discovered = preferences == null
        ? _defaultDiscovered
        : (await preferences.getStringList(_discoveredKey))?.toSet() ??
              _defaultDiscovered;
    _newPigeonIds =
        (await preferences?.getStringList(_newKey))
            ?.where(discovered.contains)
            .toSet() ??
        {};
    _claimedCollectionGoalIds =
        (await preferences?.getStringList(_collectionGoalsKey))?.toSet() ?? {};
    _ownedKeepsakeIds =
        (await preferences?.getStringList(_keepsakesKey))?.toSet() ?? {};
    _equippedAccessories.addAll(
      _decodeEquipment(
        await preferences?.getStringList(_equippedAccessoriesKey),
      ),
    );
    _equippedCompanions.addAll(
      _decodeEquipment(
        await preferences?.getStringList(_equippedCompanionsKey),
      ),
    );
    equipmentTutorialSeen =
        await preferences?.getBool(_equipmentTutorialKey) ?? false;
    souvenirTutorialSeen =
        await preferences?.getBool(_souvenirTutorialKey) ?? false;

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
      final attempts = await preferences?.getInt(
        'pigeon.$id.keepsake_attempts',
      );
      if (attempts != null) _keepsakeAttempts[id] = attempts;
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
    if (isNew) _newPigeonIds.add(id);
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
    final isNew = !current.discovered;
    _progress[id] = current.copyWith(discovered: true, visits: 1);
    if (isNew) _newPigeonIds.add(id);
    notifyListeners();
    await _saveDiscovered();
  }

  Future<void> markPigeonSeen(String id) async {
    if (!_newPigeonIds.remove(id)) return;
    notifyListeners();
    await _preferences?.setStringList(_newKey, _newPigeonIds.toList());
  }

  Future<bool> claimCollectionGoal(CollectionGoal goal) async {
    if (!canClaimCollectionGoal(goal)) return false;
    _claimedCollectionGoalIds.add(goal.id);
    notifyListeners();
    await _preferences?.setStringList(
      _collectionGoalsKey,
      _claimedCollectionGoalIds.toList(),
    );
    return true;
  }

  Future<KeepsakeDrop?> tryFindKeepsake(String pigeonId) async {
    final progress = progressFor(pigeonId);
    if (!progress.isMaxFriendship) return null;
    final pigeon = pigeons.firstWhere((item) => item.id == pigeonId);
    final attempts = (_keepsakeAttempts[pigeonId] ?? 0) + 1;
    final baseChance = keepsakeBaseChance(pigeon);
    final guaranteeAt = switch (pigeon.rarity) {
      PigeonRarity.common => 100,
      PigeonRarity.rare => 250,
      PigeonRarity.epic => 500,
      PigeonRarity.legendary => 1000,
    };
    final chance = (baseChance * (1 + attempts / 25)).clamp(
      baseChance,
      baseChance * 10,
    );
    final found = attempts >= guaranteeAt || _random.nextDouble() < chance;
    _keepsakeAttempts[pigeonId] = found ? 0 : attempts;
    await _preferences?.setInt(
      'pigeon.$pigeonId.keepsake_attempts',
      _keepsakeAttempts[pigeonId]!,
    );
    if (!found) return null;

    final keepsake = keepsakeForPigeon(pigeonId);
    final duplicate = !_ownedKeepsakeIds.add(keepsake.id);
    if (!duplicate) {
      await _preferences?.setStringList(
        _keepsakesKey,
        _ownedKeepsakeIds.toList(),
      );
    }
    notifyListeners();
    return KeepsakeDrop(
      keepsake: keepsake,
      isDuplicate: duplicate,
      featherReward: duplicate
          ? switch (pigeon.rarity) {
              PigeonRarity.common => 1,
              PigeonRarity.rare => 2,
              PigeonRarity.epic => 4,
              PigeonRarity.legendary => 10,
            }
          : 0,
    );
  }

  Future<void> toggleKeepsake(
    PigeonKeepsake keepsake, {
    String? forPigeonId,
  }) async {
    if (!ownsKeepsake(keepsake.id) || keepsake.kind == KeepsakeKind.souvenir) {
      return;
    }
    final targetPigeonId = forPigeonId ?? keepsake.pigeonId;
    if (!progressFor(targetPigeonId).discovered) return;
    final equipment = keepsake.kind == KeepsakeKind.accessory
        ? _equippedAccessories
        : _equippedCompanions;
    if (equipment[targetPigeonId] == keepsake.id) {
      equipment.remove(targetPigeonId);
    } else {
      equipment[targetPigeonId] = keepsake.id;
    }
    notifyListeners();
    await _preferences?.setStringList(
      keepsake.kind == KeepsakeKind.accessory
          ? _equippedAccessoriesKey
          : _equippedCompanionsKey,
      _encodeEquipment(equipment),
    );
  }

  Future<void> markEquipmentTutorialSeen() async {
    if (equipmentTutorialSeen) return;
    equipmentTutorialSeen = true;
    notifyListeners();
    await _preferences?.setBool(_equipmentTutorialKey, true);
  }

  Future<void> markSouvenirTutorialSeen() async {
    if (souvenirTutorialSeen) return;
    souvenirTutorialSeen = true;
    notifyListeners();
    await _preferences?.setBool(_souvenirTutorialKey, true);
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
      await preferences.remove(_newKey);
      await preferences.remove(_collectionGoalsKey);
      await preferences.remove(_keepsakesKey);
      await preferences.remove(_equippedAccessoriesKey);
      await preferences.remove(_equippedCompanionsKey);
      await preferences.remove(_equipmentTutorialKey);
      await preferences.remove(_souvenirTutorialKey);
      for (final id in _progress.keys) {
        await preferences.remove('pigeon.$id.affection');
        await preferences.remove('pigeon.$id.friendship_points');
        await preferences.remove('pigeon.$id.visits');
        await preferences.remove(_milestonesKey(id));
        await preferences.remove('pigeon.$id.keepsake_attempts');
      }
    }
    _progress.clear();
    _claimedFriendshipMilestones.clear();
    _newPigeonIds.clear();
    _claimedCollectionGoalIds.clear();
    _ownedKeepsakeIds.clear();
    _keepsakeAttempts.clear();
    _equippedAccessories.clear();
    _equippedCompanions.clear();
    equipmentTutorialSeen = false;
    souvenirTutorialSeen = false;
    await load();
  }

  String _milestonesKey(String id) => 'pigeon.$id.friendship_milestones';

  Future<void> _saveDiscovered() async {
    final discovered = _progress.entries
        .where((entry) => entry.value.discovered)
        .map((entry) => entry.key)
        .toList();
    await _preferences?.setStringList(_discoveredKey, discovered);
    await _preferences?.setStringList(_newKey, _newPigeonIds.toList());
  }

  Map<String, String> _decodeEquipment(List<String>? values) => {
    for (final value in values ?? const <String>[])
      if (value.split('|') case [final pigeonId, final keepsakeId])
        pigeonId: keepsakeId,
  };

  List<String> _encodeEquipment(Map<String, String> values) =>
      values.entries.map((entry) => '${entry.key}|${entry.value}').toList();
}
