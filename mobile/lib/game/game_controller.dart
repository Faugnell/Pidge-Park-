import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/food.dart';
import '../models/pigeon.dart';
import '../models/treasure.dart';

class EncounterResult {
  const EncounterResult({
    required this.pigeon,
    required this.isNew,
    required this.reward,
    this.unlockedTreasure,
  });

  final Pigeon pigeon;
  final bool isNew;
  final int reward;
  final PigeonTreasure? unlockedTreasure;
}

class GameController extends ChangeNotifier {
  GameController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
    bool? useFastTimers,
    DateTime Function()? now,
    Random? random,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null,
       useFastTimers = useFastTimers ?? kDebugMode,
       _now = now ?? DateTime.now,
       _random = random ?? Random();

  static const _crumbsKey = 'game.crumbs';
  static const _feathersKey = 'game.feathers';
  static const _foodKey = 'game.active_food';
  static const _arrivalKey = 'game.arrival_at';

  final SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final Random _random;
  final bool useFastTimers;

  int crumbs = 1240;
  int feathers = 35;
  String? activeFoodId;
  DateTime? arrivalAt;

  Food? get activeFood => foodById(activeFoodId);
  bool get hasActiveFood => activeFood != null && arrivalAt != null;
  bool get visitorReady => hasActiveFood && !arrivalAt!.isAfter(_now());
  Duration get remaining {
    if (!hasActiveFood || visitorReady) return Duration.zero;
    return arrivalAt!.difference(_now());
  }

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) return;

    crumbs = await preferences.getInt(_crumbsKey) ?? 1240;
    feathers = await preferences.getInt(_feathersKey) ?? 35;
    activeFoodId = await preferences.getString(_foodKey);
    final arrival = await preferences.getString(_arrivalKey);
    arrivalAt = arrival == null ? null : DateTime.tryParse(arrival);

    if (activeFood == null) {
      activeFoodId = null;
      arrivalAt = null;
    }
    notifyListeners();
  }

  bool canAfford(Food food) => crumbs >= food.price;

  Future<bool> spendCrumbs(int amount) async {
    if (amount < 0 || crumbs < amount) return false;
    crumbs -= amount;
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> addReward({required int crumbs, int feathers = 0}) async {
    this.crumbs += crumbs;
    this.feathers += feathers;
    notifyListeners();
    await _save();
  }

  Future<bool> exchangeFeathersForCrumbs({
    required int featherCost,
    required int crumbAmount,
  }) async {
    if (featherCost <= 0 || crumbAmount <= 0 || feathers < featherCost) {
      return false;
    }
    feathers -= featherCost;
    crumbs += crumbAmount;
    notifyListeners();
    await _save();
    return true;
  }

  Future<bool> placeFood(Food food) async {
    if (hasActiveFood || !canAfford(food)) return false;

    crumbs -= food.price;
    activeFoodId = food.id;
    final duration = useFastTimers ? food.debugDuration : food.duration;
    arrivalAt = _now().add(duration);
    notifyListeners();
    await _save();
    return true;
  }

  Future<EncounterResult?> meetVisitor(
    PigeonCollectionController collection, {
    Set<String> decorationIds = const {},
  }) async {
    final food = activeFood;
    if (food == null || !visitorReady) return null;

    final hour = _now().hour;
    final period = hour >= 20 || hour < 6
        ? VisitPeriod.night
        : hour < 11
        ? VisitPeriod.morning
        : VisitPeriod.any;
    final eligible = pigeons.where((pigeon) {
      if ({17, 19, 20}.contains(pigeon.number)) return false;
      final foodMatches =
          pigeon.foodIds.isEmpty || pigeon.foodIds.contains(food.id);
      final decorationsMatch = pigeon.decorationIds.every(
        decorationIds.contains,
      );
      final periodMatches =
          pigeon.period == VisitPeriod.any || pigeon.period == period;
      return foodMatches && decorationsMatch && periodMatches;
    }).toList();
    final candidates = eligible.isEmpty
        ? pigeons
              .where((pigeon) => food.visitorIds.contains(pigeon.id))
              .toList()
        : eligible;
    final bestScore = candidates
        .map(_conditionScore)
        .reduce((first, second) => first > second ? first : second);
    final bestCandidates = candidates
        .where((pigeon) => _conditionScore(pigeon) == bestScore)
        .toList();
    final pigeon = bestCandidates[_random.nextInt(bestCandidates.length)];
    final affectionBefore = collection.progressFor(pigeon.id).affection;
    final isNew = await collection.recordVisit(pigeon.id);
    final affectionAfter = collection.progressFor(pigeon.id).affection;
    final possibleTreasure = treasureForPigeon(pigeon.id);
    final unlockedTreasure =
        possibleTreasure != null &&
            affectionBefore < possibleTreasure.requiredAffection &&
            affectionAfter >= possibleTreasure.requiredAffection
        ? possibleTreasure
        : null;
    final reward = switch (pigeon.rarity) {
      PigeonRarity.common => 20 + _random.nextInt(31),
      PigeonRarity.rare => 50 + _random.nextInt(51),
      PigeonRarity.epic => 100 + _random.nextInt(151),
      PigeonRarity.legendary => 500,
    };

    crumbs += reward;
    activeFoodId = null;
    arrivalAt = null;
    notifyListeners();
    await _save();
    return EncounterResult(
      pigeon: pigeon,
      isNew: isNew,
      reward: reward,
      unlockedTreasure: unlockedTreasure,
    );
  }

  int _conditionScore(Pigeon pigeon) {
    return pigeon.foodIds.length +
        pigeon.decorationIds.length +
        (pigeon.period == VisitPeriod.any ? 0 : 1);
  }

  Future<void> resetAllData() async {
    final preferences = _preferences;
    if (preferences != null) {
      await preferences.remove(_crumbsKey);
      await preferences.remove(_feathersKey);
      await preferences.remove(_foodKey);
      await preferences.remove(_arrivalKey);
    }
    crumbs = 1240;
    feathers = 35;
    activeFoodId = null;
    arrivalAt = null;
    notifyListeners();
  }

  Future<void> _save() async {
    final preferences = _preferences;
    if (preferences == null) return;
    await Future.wait([
      preferences.setInt(_crumbsKey, crumbs),
      preferences.setInt(_feathersKey, feathers),
      if (activeFoodId != null)
        preferences.setString(_foodKey, activeFoodId!)
      else
        preferences.remove(_foodKey),
      if (arrivalAt != null)
        preferences.setString(_arrivalKey, arrivalAt!.toIso8601String())
      else
        preferences.remove(_arrivalKey),
    ]);
  }
}
