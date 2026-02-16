import 'package:hive_flutter/hive_flutter.dart';

import '../models/history/recipe_history_entry.dart';

class HistoryRepository {
  static const String _boxName = 'history_box';
  static const String _itemsKey = 'history_entries_v1';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  static Box<dynamic> get _safeBox {
    if (_box == null) {
      throw Exception('HistoryRepository not initialized');
    }
    return _box!;
  }

  static List<RecipeHistoryEntry> getEntries() {
    final raw = _safeBox.get(_itemsKey);
    if (raw is! List) return <RecipeHistoryEntry>[];

    final entries = raw
        .whereType<Map>()
        .map((e) => RecipeHistoryEntry.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();

    entries.sort((a, b) => b.createdAtMillis.compareTo(a.createdAtMillis));
    return entries;
  }

  static Future<void> saveEntry(RecipeHistoryEntry entry) async {
    final entries = getEntries();
    entries.insert(0, entry);
    await _safeBox.put(_itemsKey, entries.map((e) => e.toMap()).toList());
  }

  static Future<void> deleteEntry(String id) async {
    final entries = getEntries()..removeWhere((e) => e.id == id);
    await _safeBox.put(_itemsKey, entries.map((e) => e.toMap()).toList());
  }
}
