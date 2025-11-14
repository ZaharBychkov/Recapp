import 'package:flutter/material.dart';
import 'package:otus_food_app/models/recipe.dart';


class RecipeList extends StatelessWidget { //Создаем класс унаследованный отве виджета
   final List<Recipe> recipes;

   const RecipeList({super.key,required this.recipes});//Конструктор

   @override
   Widget build(BuildContext context) { //BuildContext - знает контекст текущего виджета и его окружение, обращаемся к нему через context
   return ListView.builder(//ListVeiw прокручивает элементы вертикально или горизонтально
      itemCount: recipes.length, //Сколько рецептов в списке
     itemBuilder: (context, index) {
       return Card( //Возвращаем конейнер оформления
           child: Padding(//Дочерний элемент внутри Card
             padding: EdgeInsets.all(8.0), //Отступы го гаризонатли
             child: Column(
               children: [
                 ClipRRect( //Обрезаем углы изображения, делая из закругленными
                   borderRadius: BorderRadius.circular(12.0), // Радиус закругления
                   child: Image.asset(//Загружаем изображения из списка
                     recipes[index].imagePath,
                     height: 200, // Фиксированная высота изображения
                     fit: BoxFit.cover, // Способ масштабирования изображения, сохраняя пропорции
                   ),
                 ),
               ],
             ),
           )
       );
     },
   );
  }
}