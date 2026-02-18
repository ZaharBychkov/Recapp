import '../fridge/fridge_item.dart';

class RecipeHistoryEntry {
  final String id;
  final int createdAtMillis;
  final int recipeId;
  final String recipeTitle;
  final String recipeImagePath;
  final List<FridgeItem> consumedItems;
  final int? restoredAtMillis;

  const RecipeHistoryEntry({
    required this.id,
    required this.createdAtMillis,
    required this.recipeId,
    required this.recipeTitle,
    required this.recipeImagePath,
    required this.consumedItems,
    this.restoredAtMillis,
  });

  bool get isRestored => restoredAtMillis != null;

  RecipeHistoryEntry copyWith({
    String? id,
    int? createdAtMillis,
    int? recipeId,
    String? recipeTitle,
    String? recipeImagePath,
    List<FridgeItem>? consumedItems,
    int? restoredAtMillis,
    bool clearRestoredAt = false,
  }) {
    return RecipeHistoryEntry(
      id: id ?? this.id,
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      recipeId: recipeId ?? this.recipeId,
      recipeTitle: recipeTitle ?? this.recipeTitle,
      recipeImagePath: recipeImagePath ?? this.recipeImagePath,
      consumedItems: consumedItems ?? this.consumedItems,
      restoredAtMillis: clearRestoredAt
          ? null
          : (restoredAtMillis ?? this.restoredAtMillis),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'createdAtMillis': createdAtMillis,
      'recipeId': recipeId,
      'recipeTitle': recipeTitle,
      'recipeImagePath': recipeImagePath,
      'consumedItems': consumedItems.map((e) => e.toMap()).toList(),
      'restoredAtMillis': restoredAtMillis,
    };
  }

  factory RecipeHistoryEntry.fromMap(Map<dynamic, dynamic> map) {
    final list = (map['consumedItems'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(FridgeItem.fromMap)
        .toList();

    return RecipeHistoryEntry(
      id: map['id'] as String,
      createdAtMillis: (map['createdAtMillis'] as num).toInt(),
      recipeId: (map['recipeId'] as num).toInt(),
      recipeTitle: map['recipeTitle'] as String,
      recipeImagePath: map['recipeImagePath'] as String,
      consumedItems: list,
      restoredAtMillis: (map['restoredAtMillis'] as num?)?.toInt(),
    );
  }
}
