import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VisitJournalEntry {
  const VisitJournalEntry({
    required this.visitedAt,
    required this.foodId,
    required this.pigeonIds,
    required this.newPigeonIds,
    required this.crumbReward,
    required this.treasureIds,
  });

  final DateTime visitedAt;
  final String foodId;
  final List<String> pigeonIds;
  final List<String> newPigeonIds;
  final int crumbReward;
  final List<String> treasureIds;

  Map<String, Object> toJson() => {
    'visitedAt': visitedAt.toIso8601String(),
    'foodId': foodId,
    'pigeonIds': pigeonIds,
    'newPigeonIds': newPigeonIds,
    'crumbReward': crumbReward,
    'treasureIds': treasureIds,
  };

  static VisitJournalEntry? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final visitedAt = DateTime.tryParse(value['visitedAt'] as String? ?? '');
    final foodId = value['foodId'] as String?;
    if (visitedAt == null || foodId == null) return null;
    return VisitJournalEntry(
      visitedAt: visitedAt,
      foodId: foodId,
      pigeonIds: List<String>.from(value['pigeonIds'] as List? ?? const []),
      newPigeonIds: List<String>.from(
        value['newPigeonIds'] as List? ?? const [],
      ),
      crumbReward: value['crumbReward'] as int? ?? 0,
      treasureIds: List<String>.from(value['treasureIds'] as List? ?? const []),
    );
  }
}

class VisitJournalController extends ChangeNotifier {
  VisitJournalController({
    SharedPreferencesAsync? preferences,
    bool persistChanges = true,
  }) : _preferences = persistChanges
           ? preferences ?? SharedPreferencesAsync()
           : null;

  static const _entriesKey = 'visit_journal.entries';
  static const maxEntries = 20;
  final SharedPreferencesAsync? _preferences;
  final List<VisitJournalEntry> _entries = [];

  List<VisitJournalEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final saved = await _preferences?.getStringList(_entriesKey) ?? const [];
    _entries
      ..clear()
      ..addAll(
        saved.map((item) {
          try {
            return VisitJournalEntry.fromJson(jsonDecode(item));
          } on FormatException {
            return null;
          }
        }).whereType<VisitJournalEntry>(),
      );
    notifyListeners();
  }

  Future<void> record(VisitJournalEntry entry) async {
    _entries.insert(0, entry);
    if (_entries.length > maxEntries) {
      _entries.removeRange(maxEntries, _entries.length);
    }
    notifyListeners();
    await _save();
  }

  Future<void> resetAllData() async {
    _entries.clear();
    await _preferences?.remove(_entriesKey);
    notifyListeners();
  }

  Future<void> _save() async {
    await _preferences?.setStringList(
      _entriesKey,
      _entries.map((entry) => jsonEncode(entry.toJson())).toList(),
    );
  }
}
