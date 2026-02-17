import 'package:hive_flutter/hive_flutter.dart';

import '../models/fridge/fridge_item.dart';
import '../domain/ingredient_unit.dart';

class FridgeRepository {
  static const String _boxName = 'fridge_box';
  static const String _itemsKey = 'items_v2';

  static Box<dynamic>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    await _seedDefaultItemsIfNeeded();
  }

  static Box<dynamic> get _safeBox {
    if (_box == null) {
      throw Exception('FridgeRepository not initialized');
    }
    return _box!;
  }

  static List<FridgeItem> getItems() {
    final raw = _safeBox.get(_itemsKey);
    if (raw is! List) return <FridgeItem>[];

    final items = raw
        .whereType<Map>()
        .map((e) => FridgeItem.fromMap(Map<dynamic, dynamic>.from(e)))
        .toList();

    return _sorted(items);
  }

  static Future<void> saveItems(List<FridgeItem> items) async {
    await _safeBox.put(_itemsKey, items.map((e) => e.toMap()).toList());
  }

  static Future<void> _seedDefaultItemsIfNeeded() async {
    final raw = _safeBox.get(_itemsKey);
    final shouldSeed = raw == null || (raw is List && raw.isEmpty);
    if (!shouldSeed) return;

    final now = DateTime.now().microsecondsSinceEpoch;
    final defaults = <FridgeItem>[
      _seedItem(id: '${now}_0', name: 'Булочка для бургера', amountBase: 2000, unit: IngredientUnit.pcs, order: 0),
      _seedItem(id: '${now}_1', name: 'Говяжья котлета', amountBase: 4000, unit: IngredientUnit.pcs, order: 1),
      _seedItem(id: '${now}_2', name: 'Салат', amountBase: 200000, unit: IngredientUnit.g, order: 2),
      _seedItem(id: '${now}_3', name: 'Помидор', amountBase: 4000, unit: IngredientUnit.pcs, order: 3),
      _seedItem(id: '${now}_4', name: 'Лук', amountBase: 4000, unit: IngredientUnit.pcs, order: 4),
      _seedItem(id: '${now}_5', name: 'Сыр чеддер', amountBase: 300000, unit: IngredientUnit.g, order: 5),
      _seedItem(id: '${now}_6', name: 'Кетчуп', amountBase: 300, unit: IngredientUnit.ml, order: 6),
      _seedItem(id: '${now}_7', name: 'Горчица', amountBase: 200, unit: IngredientUnit.ml, order: 7),
      _seedItem(id: '${now}_8', name: 'Масло для жарки', amountBase: 700, unit: IngredientUnit.ml, order: 8),
      _seedItem(id: '${now}_9', name: 'Говядина', amountBase: 1200000, unit: IngredientUnit.g, order: 9),
      _seedItem(id: '${now}_10', name: 'Чеснок', amountBase: 10000, unit: IngredientUnit.pcs, order: 10),
      _seedItem(id: '${now}_11', name: 'Сливочное масло', amountBase: 400000, unit: IngredientUnit.g, order: 11),
      _seedItem(id: '${now}_12', name: 'Сливки', amountBase: 1000, unit: IngredientUnit.ml, order: 12),
      _seedItem(id: '${now}_13', name: 'Хмели-сунели', amountBase: 120000, unit: IngredientUnit.g, order: 13),
      _seedItem(id: '${now}_14', name: 'Соль', amountBase: 300000, unit: IngredientUnit.g, order: 14),
      _seedItem(id: '${now}_15', name: 'Перец', amountBase: 120000, unit: IngredientUnit.g, order: 15),
      _seedItem(id: '${now}_16', name: 'Спагетти', amountBase: 600000, unit: IngredientUnit.g, order: 16),
      _seedItem(id: '${now}_17', name: 'Креветки', amountBase: 500000, unit: IngredientUnit.g, order: 17),
      _seedItem(id: '${now}_18', name: 'Мидии', amountBase: 400000, unit: IngredientUnit.g, order: 18),
      _seedItem(id: '${now}_19', name: 'Петрушка', amountBase: 200000, unit: IngredientUnit.g, order: 19),
      _seedItem(id: '${now}_20', name: 'Оливковое масло', amountBase: 700, unit: IngredientUnit.ml, order: 20),
      _seedItem(id: '${now}_21', name: 'Тунец', amountBase: 700000, unit: IngredientUnit.g, order: 21),
      _seedItem(id: '${now}_22', name: 'Авокадо', amountBase: 4000, unit: IngredientUnit.pcs, order: 22),
      _seedItem(id: '${now}_23', name: 'Рис', amountBase: 700000, unit: IngredientUnit.g, order: 23),
      _seedItem(id: '${now}_24', name: 'Соевый соус', amountBase: 700, unit: IngredientUnit.ml, order: 24),
      _seedItem(id: '${now}_25', name: 'Сыр фета', amountBase: 300000, unit: IngredientUnit.g, order: 25),
      _seedItem(id: '${now}_26', name: 'Огурец', amountBase: 4000, unit: IngredientUnit.pcs, order: 26),
      _seedItem(id: '${now}_27', name: 'Кунжутное масло', amountBase: 250, unit: IngredientUnit.ml, order: 27),
    ];

    await saveItems(defaults);
  }

  static FridgeItem _seedItem({
    required String id,
    required String name,
    required int amountBase,
    required IngredientUnit unit,
    required int order,
  }) {
    return FridgeItem(
      id: id,
      name: name,
      amountBase: amountBase,
      unit: unit,
      displayOrder: order,
      isDepleted: false,
    );
  }

  static Future<void> addNew({
    required String name,
    required int amountBase,
    required IngredientUnit unit,
  }) async {
    final items = getItems();
    final id = '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}';
    final nextOrder = _nextOrder(items);

    items.add(
      FridgeItem(
        id: id,
        name: name,
        amountBase: amountBase,
        unit: unit,
        displayOrder: nextOrder,
        isDepleted: amountBase <= 0,
      ),
    );

    await saveItems(_sorted(items));
  }

  static Future<void> addToExisting({
    required String itemId,
    required int deltaBase,
  }) async {
    final items = getItems();
    final index = items.indexWhere((e) => e.id == itemId);
    if (index == -1) return;

    final item = items[index];
    final nextAmount = item.amountBase + deltaBase;

    items[index] = item.copyWith(
      amountBase: nextAmount,
      isDepleted: nextAmount <= 0,
    );

    await saveItems(_sorted(items));
  }

  static Future<void> updateItem(FridgeItem updated) async {
    final items = getItems();
    final index = items.indexWhere((e) => e.id == updated.id);
    if (index == -1) return;

    items[index] = updated.copyWith(isDepleted: updated.amountBase <= 0);
    await saveItems(_sorted(items));
  }

  static Future<void> deleteItem(String itemId) async {
    final items = getItems()..removeWhere((e) => e.id == itemId);
    await saveItems(_sorted(items));
  }

  static Future<void> reorderItems(List<String> orderedIds) async {
    final items = getItems();
    final byId = {for (final i in items) i.id: i};

    final ordered = <FridgeItem>[];
    for (final id in orderedIds) {
      final item = byId[id];
      if (item != null) ordered.add(item);
    }

    // Include unseen ids to avoid accidental data loss.
    for (final item in items) {
      if (!orderedIds.contains(item.id)) ordered.add(item);
    }

    final active = ordered.where((e) => !e.isDepleted).toList();
    final depleted = ordered.where((e) => e.isDepleted).toList();

    final result = <FridgeItem>[];
    for (var i = 0; i < active.length; i++) {
      result.add(active[i].copyWith(displayOrder: i));
    }
    for (var i = 0; i < depleted.length; i++) {
      result.add(depleted[i].copyWith(displayOrder: active.length + i));
    }

    await saveItems(result);
  }

  static Future<void> restoreOrMerge(List<FridgeItem> itemsToRestore) async {
    final items = getItems();

    for (final restore in itemsToRestore) {
      final sameName = items.where((e) => e.name == restore.name).toList();

      if (sameName.isEmpty) {
        final nextOrder = _nextOrder(items);
        items.add(
          restore.copyWith(
            id: '${DateTime.now().microsecondsSinceEpoch}_${restore.name.hashCode}',
            displayOrder: nextOrder,
            isDepleted: restore.amountBase <= 0,
          ),
        );
        continue;
      }

      final sameUnit = sameName.where((e) => e.unit == restore.unit).toList();
      if (sameUnit.isNotEmpty) {
        final first = sameUnit.first;
        final index = items.indexWhere((e) => e.id == first.id);
        final mergedAmount = first.amountBase + restore.amountBase;
        items[index] = first.copyWith(
          amountBase: mergedAmount,
          isDepleted: mergedAmount <= 0,
        );
      }
    }

    await saveItems(_sorted(items));
  }

  static int _nextOrder(List<FridgeItem> items) {
    if (items.isEmpty) return 0;
    return items.map((e) => e.displayOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  static List<FridgeItem> _sorted(List<FridgeItem> items) {
    final active = items.where((e) => !e.isDepleted).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    final depleted = items.where((e) => e.isDepleted).toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    final result = <FridgeItem>[];
    for (var i = 0; i < active.length; i++) {
      result.add(active[i].copyWith(displayOrder: i));
    }
    for (var i = 0; i < depleted.length; i++) {
      result.add(depleted[i].copyWith(displayOrder: active.length + i));
    }
    return result;
  }
}
