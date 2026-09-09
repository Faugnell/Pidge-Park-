import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../collection/pigeon_collection_controller.dart';
import '../models/food.dart';
import '../models/pigeon.dart';

class EncounterResult {
  const EncounterResult({
    required this.pigeon,
    required this.isNew,
    required this.reward,
  });

  final Pigeon pigeon;
  final bool isNew;
  final int reward;
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
    PigeonCollectionController collection,
  ) async {
    final food = activeFood;
    if (food == null || !visitorReady) return null;

    final visitorId = food.visitorIds[_random.nextInt(food.visitorIds.length)];
    final pigeon = pigeons.firstWhere((item) => item.id == visitorId);
    final isNew = await collection.recordVisit(visitorId);
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
    return EncounterResult(pigeon: pigeon, isNew: isNew, reward: reward);
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
