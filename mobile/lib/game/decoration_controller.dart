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
    equippedIds = await preferences.getStringList(_equippedKey) ?? ['bench'];
    equippedIds = equippedIds.where(ownedIds.contains).take(3).toList();
    notifyListeners();
  }

  bool isOwned(ParkDecoration decoration) => ownedIds.contains(decoration.id);
  bool isEquipped(ParkDecoration decoration) =>
      equippedIds.contains(decoration.id);

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
    } else if (equippedIds.length < 3) {
      equippedIds = [...equippedIds, decoration.id];
    }
    notifyListeners();
    await _save();
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
