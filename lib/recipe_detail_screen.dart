import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/time_formatter.dart';
import 'package:flutter/services.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isCooking = false;
  int remainingTime = 0;
  Timer? timer;
  List<bool> stepCompleted = [];

  @override
  void initState() {
    super.initState();
    stepCompleted = List.generate(widget.recipe.steps.length, (index) => false);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startCooking() {
    setState(() {
      isCooking = true;
      remainingTime = widget.recipe.prepTimeSeconds;
    });

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void finishCooking() {
    setState(() {
      isCooking = false;
      timer?.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
            extendBodyBehindAppBar: true,    //Объединили AppBar StatusBar и  Body
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(kToolbarHeight),
              child: AppBar(
                backgroundColor: isCooking ? Color(0xFF2ECC71) : Colors.white,
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Text(
                  'Рецепт',
                  style: TextStyle(
                    color: Color(0xFF165932),
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

            body: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),

            child: Column(
              children: [
            if (isCooking)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(
                  color: Color(0xFF2ECC71),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Center(
                      child: Text(
                        'Таймер',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w500,
                        ),
                       ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                      child: Text(
                        formatTimeMMSS(remainingTime),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.06,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.0374,
                  vertical: MediaQuery.of(context).size.height * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.title,
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
                          formatTime(widget.recipe.prepTimeSeconds),
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
                          widget.recipe.imagePath,
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
                          width: 5,
                        ),
                      ),
                      child: Column(
                        children: widget.recipe.ingredients.map((ingredient) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.014,
                                  height: MediaQuery.of(context).size.width * 0.02,
                                  margin: EdgeInsets.only(right: 12),//Отсутп только справа от точек
                                  decoration: BoxDecoration(
                                    color: Colors.black,             //Делаем черные круги как подпункты
                                    shape: BoxShape.circle,          //Круг
                                  ),
                                ),
                                Text(
                                  ingredient.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: MediaQuery.of(context).size.width * 0.035,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
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

                    Column(
                      children: widget.recipe.steps.map((step) {
                        int index = widget.recipe.steps.indexOf(step);
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.925,
                            height: MediaQuery.of(context).size.height * 0.147,
                            decoration: BoxDecoration(
                              color: isCooking ? Colors.grey[300] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Container(
                                      width: 24,
                                      height: 27,
                                      decoration: BoxDecoration(
                                        color: isCooking ? Color(0xFF2ECC71) : Colors.grey[200],
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${step.stepNumber}',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontWeight: FontWeight.w900,
                                            fontSize: 40,
                                            height: 27 / 40,
                                            letterSpacing: 0,
                                            color: isCooking ? Colors.white : Colors.grey[400],
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
                                        color: isCooking ? Colors.white : Colors.grey[400],
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
                                          value: stepCompleted[index],
                                          onChanged: isCooking
                                              ? (value) {
                                            setState(() {
                                              stepCompleted[index] = value ?? false;
                                            });
                                          }
                                              : null,
                                          activeColor: isCooking ? Color(0xFF2ECC71) : Colors.grey[600],
                                          checkColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                          side: BorderSide(
                                            color: isCooking ? Color(0xFF2ECC71) : Colors.grey[600]!,
                                            width: 2,
                                          ),
                                          splashRadius: 15,
                                        ),
                                      ),
                                      Text(
                                        formatTimeMMSS(step.timeInSeconds),
                                        style: TextStyle(
                                          color: isCooking ? Colors.white : Colors.grey[600],
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
                          onPressed: isCooking ? finishCooking : startCooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCooking ? Colors.white : Color(0xFF165932),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isCooking ? Color(0xFF165932) : Colors.transparent,
                                width: isCooking ? 2 : 0,
                              ),
                            ),
                          ),
                          child: Text(
                            isCooking ? 'Закончить готовить' : 'Начать готовить',
                            style: TextStyle(
                              color: isCooking ? Color(0xFF165932) : Colors.white,
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
          ],
        ),
      ),
        );
  }
}