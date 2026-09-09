import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PigeonProgress {
  const PigeonProgress({
    required this.discovered,
    required this.affection,
    required this.visits,
  });

  final bool discovered;
  final int affection;
  final int visits;

  PigeonProgress copyWith({bool? discovered, int? affection, int? visits}) {
    return PigeonProgress(
      discovered: discovered ?? this.discovered,
      affection: affection ?? this.affection,
      visits: visits ?? this.visits,
    );
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
  static const _defaultDiscovered = <String>{
    'gilbert',
    'michel',
    'chunky',
    'kevin',
    'brenda',
    'jean_pigeon',
  };

  final SharedPreferencesAsync? _preferences;
  final Map<String, PigeonProgress> _progress = {};

  PigeonProgress progressFor(String id) {
    return _progress[id] ??
        PigeonProgress(
          discovered: _defaultDiscovered.contains(id),
          affection: id == 'gilbert' ? 7 : 3,
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
      _progress[id] = PigeonProgress(
        discovered: discovered.contains(id),
        affection:
            await preferences?.getInt('pigeon.$id.affection') ??
            defaultProgress.affection,
        visits:
            await preferences?.getInt('pigeon.$id.visits') ??
            defaultProgress.visits,
      );
    }
    notifyListeners();
  }

  Future<void> giveGift(String id) async {
    final current = progressFor(id);
    if (!current.discovered || current.affection >= 10) return;

    final updated = current.copyWith(affection: current.affection + 1);
    _progress[id] = updated;
    notifyListeners();
    await _preferences?.setInt('pigeon.$id.affection', updated.affection);
  }

  Future<bool> recordVisit(String id) async {
    final current = progressFor(id);
    final isNew = !current.discovered;
    final updated = current.copyWith(
      discovered: true,
      visits: current.visits + 1,
      affection: isNew ? 1 : (current.affection + 1).clamp(0, 10),
    );
    _progress[id] = updated;
    notifyListeners();

    await _preferences?.setInt('pigeon.$id.affection', updated.affection);
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

  Future<void> resetAllData() async {
    final preferences = _preferences;
    if (preferences != null) {
      await preferences.remove(_discoveredKey);
      for (final id in _progress.keys) {
        await preferences.remove('pigeon.$id.affection');
        await preferences.remove('pigeon.$id.visits');
      }
    }
    _progress.clear();
    await load();
  }

  Future<void> _saveDiscovered() async {
    final discovered = _progress.entries
        .where((entry) => entry.value.discovered)
        .map((entry) => entry.key)
        .toList();
    await _preferences?.setStringList(_discoveredKey, discovered);
  }
}
