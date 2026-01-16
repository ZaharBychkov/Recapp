import 'package:flutter/material.dart';
import '../models/recipe.dart'; //
import '../utils/time_formatter.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe; //

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Рецепт', //
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.045,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.0374,
            vertical: MediaQuery.of(context).size.height * 0.01,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение рецепта
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    recipe.imagePath, //
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Время приготовления
              Row(
                children: [
                  Icon(Icons.timer, color: Color(0xFF2ECC71), size: 20),
                  SizedBox(width: 5),
                  Text(
                    formatTime(recipe.prepTimeSeconds), //
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Ингредиенты
              Text(
                'Ингредиенты',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              // Контейнер для работы с ингредиентами
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Column(
                  children: recipe.ingredients.map((ingredient) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: MediaQuery.of(context).size.width * 0.03,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            '', //
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: MediaQuery.of(context).size.width * 0.03,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Описание (вместо шагов)
              Text(
                'Описание',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              // Текст описания
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD9D9D9)),
                ),
                child: Text(
                  recipe.description, //
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: MediaQuery.of(context).size.width * 0.03,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              // Кнопка "начать готовить"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2ECC71),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Начать готовить',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}