import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_cycle.dart';
import 'game_controller.dart';

class DailyGiftController extends ChangeNotifier {
  DailyGiftController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
    DateTime Function()? now,
    this.cycle = const DailyCycle(),
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null,
       _now = now ?? DateTime.now;

  static const rewardAmount = 100;
  static const _lastClaimedKey = 'daily_gift.last_claimed';

  final SharedPreferencesAsync? _preferences;
  final DateTime Function() _now;
  final DailyCycle cycle;
  String? lastClaimedDay;

  bool get isAvailable => lastClaimedDay != cycle.keyFor(_now());
  DateTime get nextReset => cycle.nextReset(_now());
  Duration get timeUntilReset => nextReset.difference(_now());

  Future<void> load() async {
    lastClaimedDay = await _preferences?.getString(_lastClaimedKey);
    notifyListeners();
  }

  Future<bool> claim(GameController gameController) async {
    if (!isAvailable) return false;
    lastClaimedDay = cycle.keyFor(_now());
    await gameController.addReward(crumbs: rewardAmount);
    await _preferences?.setString(_lastClaimedKey, lastClaimedDay!);
    notifyListeners();
    return true;
  }

  Future<void> resetAllData() async {
    await _preferences?.remove(_lastClaimedKey);
    lastClaimedDay = null;
    notifyListeners();
  }
}
