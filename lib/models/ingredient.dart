class Ingredient {
  final String name;
  final String measurement;
  Ingredient({required this.name, required this.measurement});

  @override
  String toString() => '$name: $measurement';
}