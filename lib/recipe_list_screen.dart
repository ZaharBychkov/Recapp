import 'package:flutter/material.dart';
import '../recipe_manager.dart';
import '../models/recipe.dart';

class RecipeListScreen extends StatefulWidget {
  @override
  //Создаем стэйт (управляющего для данного класса)
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

//Привязываем стэйт к классу
class _RecipeListScreenState extends State<RecipeListScreen> {
  late List<Recipe> recipes;

  //Инициализируем стэйт(управляющего) передаем ему данные для работы
  @override
  void initState() {
    super.initState();
    recipes = RecipeManager().getRecipes();//Передаем список рецептов из другого файла
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECECEC),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.0374
          ),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.026,),
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,//Передаем количество картинок
                  //Context - ссылка на виджет в котором он находится чтобы itemBuilder понимал где он
                  //index - индекс для картинок
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Container(//Контейнер в который будут устанавливаться изображения
                      margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.017,
                      ),
                      width: MediaQuery.of(context).size.width * 0.925,
                      height: MediaQuery.of(context).size.height * 0.147,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),//Обрезает сам контеинер
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),//Обрезает child - картинку
                        child: Image.asset(//asset - устновка изображения
                          recipe.imagePath,//Берет изображение по пути
                          fit: BoxFit.cover,//Заполняет весь контейнер изображением обрезая лишнее
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.08,
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/pizza_green.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Рецепты',
                      style: TextStyle(
                        color: Color(0xFF2ECC71),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Icons/person_grey.png',
                      width: MediaQuery.of(context).size.width * 0.056,
                    ),
                    Text(
                      'Вход',
                      style: TextStyle(
                        color: Color(0xFFC2C2C2),
                        fontSize: MediaQuery.of(context).size.width * 0.0234,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
