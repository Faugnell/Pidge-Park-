import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/game_controller.dart';
import '../models/decoration.dart';

class DecorationController extends ChangeNotifier {
  DecorationController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null;

  static const _ownedKey = 'decorations.owned';
  static const _equippedKey = 'decorations.equipped';
  final SharedPreferencesAsync? _preferences;

  Set<String> ownedIds = {'bench'};
  List<String> equippedIds = ['bench'];

  Future<void> load() async {
    final preferences = _preferences;
    if (preferences == null) return;
    ownedIds =
        (await preferences.getStringList(_ownedKey))?.toSet() ?? {'bench'};
    final savedEquipped =
        await preferences.getStringList(_equippedKey) ?? ['bench'];
    equippedIds = _onePerSize(savedEquipped.where(ownedIds.contains));
    notifyListeners();
  }

  bool isOwned(ParkDecoration decoration) => ownedIds.contains(decoration.id);
  bool isEquipped(ParkDecoration decoration) =>
      equippedIds.contains(decoration.id);

  ParkDecoration? equippedFor(DecorationSize size) {
    for (final id in equippedIds) {
      final decoration = decorations.firstWhere((item) => item.id == id);
      if (decoration.size == size) return decoration;
    }
    return null;
  }

  Future<bool> buy(ParkDecoration decoration, GameController game) async {
    if (isOwned(decoration) || game.crumbs < decoration.price) return false;
    await game.spendCrumbs(decoration.price);
    ownedIds = {...ownedIds, decoration.id};
    notifyListeners();
    await _save();
    return true;
  }

  Future<void> toggleEquipped(ParkDecoration decoration) async {
    if (!isOwned(decoration)) return;
    if (isEquipped(decoration)) {
      equippedIds = equippedIds.where((id) => id != decoration.id).toList();
    } else {
      equippedIds = [
        for (final id in equippedIds)
          if (decorations.firstWhere((item) => item.id == id).size !=
              decoration.size)
            id,
        decoration.id,
      ];
    }
    notifyListeners();
    await _save();
  }

  List<String> _onePerSize(Iterable<String> ids) {
    final result = <String>[];
    final occupied = <DecorationSize>{};
    for (final id in ids) {
      final matches = decorations.where((item) => item.id == id);
      if (matches.isEmpty) continue;
      final decoration = matches.first;
      if (occupied.add(decoration.size)) result.add(id);
    }
    return result;
  }

  Future<void> resetAllData() async {
    await _preferences?.remove(_ownedKey);
    await _preferences?.remove(_equippedKey);
    ownedIds = {'bench'};
    equippedIds = ['bench'];
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences?.setStringList(_ownedKey, ownedIds.toList());
    await _preferences?.setStringList(_equippedKey, equippedIds);
  }
}
