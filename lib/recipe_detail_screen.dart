import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/time_formatter.dart';
import 'package:flutter/services.dart';
import '../models/comment.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isLoggedIn;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.isLoggedIn = true,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  bool isCooking = false;
  bool isFavorite = false;
  int remainingTime = 0;
  Timer? timer;
  List<bool> stepCompleted = [];
  String? selectedCommentImage;

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

  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  List<Comment> comments = [
    Comment(
      author: "anna_obraztsove",
      text:
          "Я не большой любитель рыбы, но решила приготовить по этому рецепту и просто влюбилась!",
      imageUrl: "assets/Images/burger_with_two_cutlets.png",
    ),
  ];

  //Комментарии
  Widget _buildComment(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Аватар сверху
        children: [
          // АВАТАР - flex 1
          Expanded(
            flex: 1,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFF165932), width: 2),
                color: Colors.white,
              ),
              child: ClipOval(
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Image.asset(
                    'assets/Icons/empty_avatar.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12),

          // КОНТЕНТ КОММЕНТАРИЯ - flex 4
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // РЯД: Логин и дата
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        comment.author,
                        style: TextStyle(
                          color: Color(0xFF2ECC71),
                          fontSize: MediaQuery.of(context).size.width * 0.035,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        comment.createdAt.toIso8601String().substring(0, 10),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  // ТЕКСТ КОММЕНТАРИЯ
                  Text(
                    comment.text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    softWrap: true, // Автоматический перенос строк
                  ),

                  // ИЗОБРАЖЕНИЕ (если есть)
                  if (comment.imageUrl != null) ...[
                    SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        comment.imageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Кнопка оставить комментарий
  void _openCommentInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 10,
            right: 10,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.14,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xff165932), width: 3),
            ),
            child: Stack(
              children: [
                TextField(
                  autofocus: true,
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Оставить комментарий',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.04,
                      right: MediaQuery.of(context).size.width * 0.12,
                      top: MediaQuery.of(context).size.height * 0.02,
                      bottom: MediaQuery.of(context).size.height * 0.02,
                    ),
                  ),
                ),

                Positioned(
                  top: MediaQuery.of(context).size.height * 0.012,
                  right: MediaQuery.of(context).size.width * 0.02,
                  child: Image.asset(
                    'assets/Icons/paste_image.png',
                    width: MediaQuery.of(context).size.width * 0.06,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Основной контент
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: isCooking
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: Offset(0, 3),
                      blurRadius: 2,
                    ),
                  ],
          ),
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
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
        ),
        child: Column(
          children: [
            // ТАЙМЕР
            if (isCooking)
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.1,
                decoration: BoxDecoration(color: Color(0xFF2ECC71)),
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

            // ОДИН ОБЩИЙ СКРОЛЛ
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ПЕРВЫЙ БЛОК С PADDING - основной контент рецепта
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0374,
                        vertical: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Заголовок рецепта
                          if (widget.isLoggedIn)
                            Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    widget.recipe.title,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.06,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      height: 1.2,
                                    ),
                                    maxLines: null,
                                    softWrap: true,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: toggleFavorite,
                                    child: Image.asset(
                                      isFavorite
                                          ? 'assets/Icons/heart_red.png'
                                          : 'assets/Icons/heart_black.png',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              widget.recipe.title,
                              style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                                fontFamily: 'Roboto',
                                height: 1.2,
                              ),
                              maxLines: null,
                              softWrap: true,
                            ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),

                          // Время приготовления
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
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.035,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),

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
                                widget.recipe.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Ингредиенты
                          Text(
                            'Ингредиенты',
                            style: TextStyle(
                              color: Color(0xFF165932),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),

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
                              children: widget.recipe.ingredients.map((
                                ingredient,
                              ) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.014,
                                        height:
                                            MediaQuery.of(context).size.width *
                                            0.02,
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
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.035,
                                          fontFamily: 'Roboto',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Text(
                                        ingredient.measurement,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.033,
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

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Кнопка "Проверить наличие"
                          if (widget.isLoggedIn)
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: Color(0xFF165932),
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'Проверить наличие',
                                    style: TextStyle(
                                      color: Color(0xFF165932),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.04,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Шаги приготовления
                          Text(
                            'Шаги приготовления',
                            style: TextStyle(
                              color: Color(0xFF165932),
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),

                          Column(
                            children: widget.recipe.steps.map((step) {
                              int index = widget.recipe.steps.indexOf(step);
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.925,
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.147,
                                  decoration: BoxDecoration(
                                    color: isCooking
                                        ? Color(0xFFe0f7ea)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Center(
                                          child: Container(
                                            width: 24,
                                            height: 27,
                                            decoration: BoxDecoration(
                                              color: isCooking
                                                  ? Color(0xFFe0f7ea)
                                                  : Colors.grey[200],
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
                                                  color: isCooking
                                                      ? Color(0xFF2ECC71)
                                                      : Colors.grey[400],
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
                                              color: isCooking
                                                  ? Color(0xff2D490C)
                                                  : Colors.grey[400],
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.03,
                                              fontFamily: 'Roboto',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Transform.scale(
                                              scale: 1.7,
                                              child: Checkbox(
                                                value: stepCompleted[index],
                                                onChanged: isCooking
                                                    ? (value) {
                                                        setState(() {
                                                          stepCompleted[index] =
                                                              value ?? false;
                                                        });
                                                      }
                                                    : null,
                                                activeColor: isCooking
                                                    ? Color(0xFF165932)
                                                    : Colors.grey[600],
                                                checkColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                side: BorderSide(
                                                  color: isCooking
                                                      ? Color(0xFF165932)
                                                      : Colors.grey[600]!,
                                                  width: 2,
                                                ),
                                                splashRadius: 15,
                                              ),
                                            ),
                                            Text(
                                              formatTimeMMSS(
                                                step.timeInSeconds,
                                              ),
                                              style: TextStyle(
                                                color: isCooking
                                                    ? Color(0xff165932)
                                                    : Colors.grey[600],
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.035,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w700,
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

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Кнопка "Начать готовить"
                          Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: ElevatedButton(
                                onPressed: isCooking
                                    ? finishCooking
                                    : startCooking,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isCooking
                                      ? Colors.white
                                      : Color(0xFF165932),
                                  padding: EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: isCooking
                                          ? Color(0xFF165932)
                                          : Colors.transparent,
                                      width: isCooking ? 4 : 0,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  isCooking
                                      ? 'Закончить готовить'
                                      : 'Начать готовить',
                                  style: TextStyle(
                                    color: isCooking
                                        ? Color(0xFF165932)
                                        : Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.04,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                        ],
                      ),
                    ),

                    if (widget.isLoggedIn)
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: Colors.black,
                      ),

                    // ЛИНИЯ БЕЗ PADDING - на всю ширину экрана
                    if (widget.isLoggedIn)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),
                            ...comments
                                .map((comment) => _buildComment(comment))
                                .toList(),
                            SizedBox(height: MediaQuery.of(context).size.height * 0.01,),


                                Padding(
                                  padding: EdgeInsets.only(bottom: 15),
                                  child: GestureDetector(
                                  onTap: _openCommentInput,
                                  child: Container(
                                    width: double.infinity,
                                    height: MediaQuery.of(context).size.height * 0.09,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Color(0xff165932), width: 3),
                                    ),
                                    child: Stack(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: MediaQuery.of(context,).size.width * 0.04,
                                            right: MediaQuery.of(context,).size.width * 0.12,
                                            top: MediaQuery.of(context,).size.height * 0.02,
                                            bottom: MediaQuery.of(context,).size.height * 0.02,
                                          ),
                                          child: Text(
                                            'Оставить комментарий',
                                            style: TextStyle(
                                              color: Color(0xffc2c2c2),
                                              fontSize: MediaQuery.of(context).size.width * 0.037,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: MediaQuery.of(context).size.height * 0.012,
                                          right: MediaQuery.of(context).size.width * 0.02,
                                          child: Image.asset(
                                            'assets/Icons/paste_image.png',
                                            width: MediaQuery.of(context).size.width * 0.06,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ),

                                // Column(
                                //   children: [
                                //     Container(
                                //       height: MediaQuery.of(context).size.height * 0.14, // 0.14–0.18
                                //       decoration: BoxDecoration(
                                //         borderRadius: BorderRadius.circular(12),
                                //         border: Border.all(
                                //           color: Color(0xff165932),
                                //           width: 3,
                                //         ),
                                //       ),
                                //       child: Stack(
                                //         children: [
                                //           // TEXTFIELD
                                //           TextField(
                                //             maxLines: null,
                                //             expands: true,
                                //             keyboardType: TextInputType.multiline,
                                //             textAlignVertical: TextAlignVertical.top,
                                //             decoration: InputDecoration(
                                //               hintText: 'Оставить комментарий',
                                //               hintStyle: TextStyle(
                                //                 color: Color(0xffc2c2c2),
                                //                 fontSize: MediaQuery.of(context,).size.width * 0.037,
                                //                 fontFamily: 'Roboto',
                                //               ),
                                //               border: InputBorder.none,
                                //               contentPadding: EdgeInsets.only(
                                //                 left: MediaQuery.of(context,).size.width * 0.04,
                                //                 right: MediaQuery.of(context,).size.width * 0.12,
                                //                 top: MediaQuery.of(context,).size.height * 0.02,
                                //                 bottom: MediaQuery.of(context,).size.height * 0.02,
                                //               ),
                                //             ),
                                //           ),
                                //
                                //           // ИКОНКА ДОБАВЛЕНИЯ ИЗОБРАЖЕНИЯ
                                //           Positioned(
                                //             top: MediaQuery.of(context).size.height * 0.012,
                                //             right: MediaQuery.of(context,).size.width * 0.02,
                                //             child: InkWell(
                                //               onTap: () {
                                //                 setState(() {
                                //                   selectedCommentImage =
                                //                       'assets/Images/salmon_in_teriyaki_sauce.png';
                                //                 });
                                //               },
                                //               borderRadius: BorderRadius.circular(8),
                                //               child: Padding(
                                //                 padding: EdgeInsets.all(MediaQuery.of(context,).size.width * 0.015,),
                                //                 child: Image.asset(
                                //                   'assets/Icons/paste_image.png',
                                //                   width: MediaQuery.of(context).size.width * 0.06,
                                //                 ),
                                //               ),
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //     ),
                                //   ],
                                // ),
                          ],
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
