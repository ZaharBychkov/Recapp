import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/time_formatter.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              'Рецепт',
              style: TextStyle(
                color: Color(0xFF165932),
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
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.0374,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.title,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  fontFamily: 'Roboto',
                  height: 1.2,
                ),
                maxLines: null,
                softWrap: true,
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.015),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 4),
                  Image.asset(
                    'assets/Icons/clock.png',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    formatTime(recipe.prepTimeSeconds),
                    style: TextStyle(
                      color: Color(0xFF2ECC71),
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.015),

              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    recipe.imagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Text(
                'Ингредиенты',
                style: TextStyle(
                  color: Color(0xFF165932),
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Color(0xFFA0A0A0),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: recipe.ingredients.map((ingredient) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Text(
                            ingredient.name,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.03,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Spacer(),
                          Text(
                            ingredient.measurement,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: MediaQuery.of(context).size.width * 0.033,
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

              Text(
                'Шаги приготовления',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.01),

              //Шаги приготовления
              Column(
                children: recipe.steps.map((step) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.925,
                      height: MediaQuery.of(context).size.height * 0.147,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Container(
                                width: 24, // Ширина 24px
                                height: 27, // Высота 27px
                                decoration: BoxDecoration(
                                  color: Colors.grey[200], // Цвет #C2C2C2
                                ),
                                child: Center(
                                  child: Text(
                                    '${step.stepNumber}',
                                    style: TextStyle(
                                      fontFamily: 'Roboto', // Шрифт Roboto
                                      fontWeight: FontWeight.w900, // Жирность 900 (Black)
                                      fontSize: 40, // Размер 40px
                                      height: 27 / 40,
                                      letterSpacing: 0, // Letter spacing 0%
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 5,
                            child: Center(
                              child: Text(
                                step.description,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: MediaQuery.of(context).size.width * 0.03,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                  Transform.scale(
                                  scale: 1.7,
                                  child: Checkbox(
                                    value: step.isCompleted,
                                    onChanged: (value) {
                                    // setState нельзя использовать в Stateless
                                    },
                                  activeColor: Colors.grey[600],
                                  checkColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  side: BorderSide(
                                    color: Colors.grey[600]!,
                                    width: 2,
                                  ),
                                  splashRadius: 15,
                                ),
                                ),
                                Text(
                                  formatTimeMMSS(step.timeInSeconds),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: MediaQuery.of(context).size.width * 0.025,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF165932),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}