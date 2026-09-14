import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/pigeon.dart';
import 'decoration_controller.dart';

enum AchievementType {
  firstFlock,
  discoverFive,
  discoverFifteen,
  bestFriend,
  decorator,
  foodExplorer,
  parkRegular,
  treasureHunter,
}

class Achievement {
  const Achievement({
    required this.type,
    required this.target,
    required this.feathers,
  });
  final AchievementType type;
  final int target;
  final int feathers;
}

const achievements = <Achievement>[
  Achievement(type: AchievementType.firstFlock, target: 1, feathers: 2),
  Achievement(type: AchievementType.discoverFive, target: 5, feathers: 5),
  Achievement(type: AchievementType.discoverFifteen, target: 15, feathers: 12),
  Achievement(type: AchievementType.bestFriend, target: 1, feathers: 10),
  Achievement(type: AchievementType.decorator, target: 3, feathers: 4),
  Achievement(type: AchievementType.foodExplorer, target: 5, feathers: 6),
  Achievement(type: AchievementType.parkRegular, target: 7, feathers: 10),
  Achievement(type: AchievementType.treasureHunter, target: 5, feathers: 10),
];

class AchievementController extends ChangeNotifier {
  AchievementController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null;

  static const _unlockedKey = 'achievements.unlocked';
  static const _foodsKey = 'achievements.foods';
  static const _flocksKey = 'achievements.flocks';
  static const _missionDaysKey = 'achievements.mission_days';
  final SharedPreferencesAsync? _preferences;
  final Set<AchievementType> _unlocked = {};
  final Set<String> triedFoodIds = {};
  int welcomedFlocks = 0;
  int completedMissionDays = 0;

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) return;
    final names = await preferences.getStringList(_unlockedKey) ?? const [];
    _unlocked.addAll(
      AchievementType.values.where((item) => names.contains(item.name)),
    );
    triedFoodIds.addAll(await preferences.getStringList(_foodsKey) ?? const []);
    welcomedFlocks = await preferences.getInt(_flocksKey) ?? 0;
    completedMissionDays = await preferences.getInt(_missionDaysKey) ?? 0;
    notifyListeners();
  }

  bool isUnlocked(Achievement achievement) =>
      _unlocked.contains(achievement.type);

  int progressFor(
    Achievement achievement,
    PigeonCollectionController collection,
    DecorationController decorations,
  ) {
    return switch (achievement.type) {
      AchievementType.firstFlock => welcomedFlocks,
      AchievementType.discoverFive || AchievementType.discoverFifteen =>
        pigeons.where((p) => collection.progressFor(p.id).discovered).length,
      AchievementType.bestFriend =>
        pigeons
            .where((p) => collection.progressFor(p.id).affection >= 10)
            .length,
      AchievementType.decorator => decorations.equippedIds.length,
      AchievementType.foodExplorer => triedFoodIds.length,
      AchievementType.parkRegular => completedMissionDays,
      AchievementType.treasureHunter =>
        pigeons
            .where((p) => collection.hasClaimedFriendshipMilestone(p.id, 6))
            .length,
    };
  }

  Future<List<Achievement>> update({
    String? foodId,
    bool flockWelcomed = false,
    bool missionDayCompleted = false,
    required PigeonCollectionController collection,
    required DecorationController decorations,
  }) async {
    if (foodId != null) triedFoodIds.add(foodId);
    if (flockWelcomed) welcomedFlocks++;
    if (missionDayCompleted) completedMissionDays++;
    final newlyUnlocked = <Achievement>[];
    for (final achievement in achievements) {
      if (!isUnlocked(achievement) &&
          progressFor(achievement, collection, decorations) >=
              achievement.target) {
        _unlocked.add(achievement.type);
        newlyUnlocked.add(achievement);
      }
    }
    notifyListeners();
    await _save();
    return newlyUnlocked;
  }

  Future<void> resetAllData() async {
    await _preferences?.remove(_unlockedKey);
    await _preferences?.remove(_foodsKey);
    await _preferences?.remove(_flocksKey);
    await _preferences?.remove(_missionDaysKey);
    _unlocked.clear();
    triedFoodIds.clear();
    welcomedFlocks = 0;
    completedMissionDays = 0;
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences?.setStringList(
      _unlockedKey,
      _unlocked.map((e) => e.name).toList(),
    );
    await _preferences?.setStringList(_foodsKey, triedFoodIds.toList());
    await _preferences?.setInt(_flocksKey, welcomedFlocks);
    await _preferences?.setInt(_missionDaysKey, completedMissionDays);
  }
}
