import 'package:hive/hive.dart';

part 'ingredient.g.dart';          //Файл сгенерируется автоматически 

//(Создаем номера ячеек как на складе: 0 = ингредиенты, 1 = рецепты)
@HiveType(typeId: 0)        //ID для типа Ingredient, другой для Step         
class Ingredient extends HiveObject {
  @HiveField(0)
  final String name;                   //Когда Hive будет генерить адаптер, он будет использовать эти строки для генерации адаптера
                                       //Адаптер нужен чтобы перевести кодовые данные в базу смартфона
  @HiveField(1)
  final String measurement;                    

  Ingredient({
    required this.name,
    required this.measurement,
  });

  @override
  String toString() => '$name: $measurement'; //Вывод в консоль
}