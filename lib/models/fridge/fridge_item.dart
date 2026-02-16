import '../../domain/ingredient_unit.dart';

class FridgeItem {
  final String id;
  final String name;
  final int amountBase;
  final IngredientUnit unit;
  final int displayOrder;
  final bool isDepleted;

  const FridgeItem({
    required this.id,
    required this.name,
    required this.amountBase,
    required this.unit,
    required this.displayOrder,
    required this.isDepleted,
  });

  FridgeItem copyWith({
    String? id,
    String? name,
    int? amountBase,
    IngredientUnit? unit,
    int? displayOrder,
    bool? isDepleted,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amountBase: amountBase ?? this.amountBase,
      unit: unit ?? this.unit,
      displayOrder: displayOrder ?? this.displayOrder,
      isDepleted: isDepleted ?? this.isDepleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amountBase': amountBase,
      'unit': unit.name,
      'displayOrder': displayOrder,
      'isDepleted': isDepleted,
    };
  }

  factory FridgeItem.fromMap(Map<dynamic, dynamic> map) {
    return FridgeItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amountBase: (map['amountBase'] as num).round(),
      unit: IngredientUnit.values.firstWhere(
        (u) => u.name == map['unit'],
        orElse: () => IngredientUnit.g,
      ),
      displayOrder: (map['displayOrder'] as num?)?.toInt() ?? 0,
      isDepleted: map['isDepleted'] == true,
    );
  }
}
