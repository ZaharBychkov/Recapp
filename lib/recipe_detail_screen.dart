import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/time_formatter.dart';
import 'package:flutter/services.dart';
import '../models/comment.dart';
import '../services/ingredient_checker.dart';
import '../models/ingredient_check_result.dart';
import '../models/ingredient.dart';
import 'recipe_manager.dart';
import 'create_screen.dart';  // Добавляем импорт CreateRecipeScreen

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

/*
 * RecipeDetailScreen может возвращать результаты:
 * - true: рецепт был удален
 * - "edited": рецепт был отредактирован
 * - null/false: ничего не произошло
 */

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

  /*
   * Метод для перезагрузки данных рецепта из Hive
   * Теперь можно обновлять поля widget.recipe напрямую
   */
  void _reloadRecipe() {
    final updatedRecipe = RecipeManager()
        .getRecipes()
        .firstWhere((r) => r.id == widget.recipe.id);
    
    setState(() {
      // Обновляем все поля рецепта актуальными данными
      widget.recipe.title = updatedRecipe.title;
      widget.recipe.description = updatedRecipe.description;
      widget.recipe.ingredients = updatedRecipe.ingredients;
      widget.recipe.steps = updatedRecipe.steps;
      widget.recipe.prepTimeSeconds = updatedRecipe.prepTimeSeconds;
      widget.recipe.imagePath = updatedRecipe.imagePath;
      widget.recipe.isFavorite = updatedRecipe.isFavorite;
      
      // Обновляем список шагов для cooking mode
      stepCompleted = List.generate(updatedRecipe.steps.length, (index) => false);
    });
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
    showModalBottomSheet(                                          //Окно которое выезжает снизу вверх
      context: context,                                            //Передаем контекст текущего виджета
      isScrollControlled: true,                                    // Позволяет управлять высотой окна экранной клавиатуры
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,                           //Убираем закругления - Material по умолчанию с радиусом
      ),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;     //Получаем высоту клавиатуры

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: bottomInset + (MediaQuery.of(context).size.height * 0.01), // 1% от высоты экрана
            top: MediaQuery.of(context).size.height * 0.015, // 1.5% от высоты экрана
            left: MediaQuery.of(context).size.width * 0.02,
            right: MediaQuery.of(context).size.width * 0.02,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.14, // ← Добавлено: фиксированная высота
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xff165932), width: 3),
              ),
              child: Stack(                                                //Располагаем виджеты друг над другом
                children: [
                  TextField(
                    autofocus: true,                                          //При открытии окна курсор сразу ставится в поле ввода
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5, // Разрешаем ввод многострочного текста
                    textAlignVertical: TextAlignVertical.top,                   // Текст начинается с верхней части поля
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
          ),
        );
      },
    );
  }

  IngredientCheckResult _checkResult = IngredientCheckResult.idle; //Переменная _checkResult типа IngredientCheckResult хранит статус проверки,
  // по умолчанию idle не проверено

  Color _borderColor() {                    //Функция для определения цвета через статус переменной _checkResult
    switch (_checkResult) {
      case IngredientCheckResult.success:    //В зависимости от результата проверки выставляем цвет
        return Color(0xff2ecc71);
      case IngredientCheckResult.failure:
        return Colors.red;
      case IngredientCheckResult.idle:
        return Color(0xffa0a0a0);   //По умолчанию серый цвет
    }
  }

  //Основное условия и проверка
  void _checkIngredient() {
    final fridgeIngredients = [
      Ingredient(name: "Говядина", measurement: "400 г"),
      Ingredient(name: "Лук", measurement: "1 шт."),
      Ingredient(name: "Чеснок", measurement: "2 зубчика"),
      Ingredient(name: "Сливочное масло", measurement: "50 г"),
      Ingredient(name: "Сливки", measurement: "100 мл"),
      Ingredient(name: "Хмели-сунели", measurement: "1 ч. ложка"),
      Ingredient(name: "Соль", measurement: "по вкусу"),
      Ingredient(name: "Перец", measurement: "по вкусу"),
      Ingredient(name: "Масло для жарки", measurement: "2 ст. ложки"),
    ];

    //Вызываю сервис проверки
    final hasAll = IngredientChecker.hasAllIngredients(
      recipeIngredients: widget.recipe.ingredients,           //Входные данные для функции в ingredient_checkre.dart
      fridgeIngredients: fridgeIngredients,
    );

    setState(() {
      _checkResult = hasAll ? IngredientCheckResult.success : IngredientCheckResult.failure; //Обновляем состояние в зависимости от результата провреки
    });

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
                          // Заголовок рецепта с иконками действий
                          // Убрали условие if (widget.isLoggedIn) чтобы иконки всегда отображались
                          Row(
                            children: [
                                /*
                                 * Текст заголовка - занимает 4/7 пространства
                                 * Уменьшили с flex: 5 до flex: 4 чтобы освободить место для иконок
                                 */
                                Expanded(
                                  flex: 6,  // Уменьшили чтобы освободить место для иконок
                                  child: Text(
                                    widget.recipe.title,
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.07,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      fontFamily: 'Roboto',
                                      height: 1.15,
                                    ),
                                    maxLines: null,
                                    softWrap: true,
                                  ),
                                ),

                                Expanded(
                                  flex: 3,  // 3 иконки по flex: 1 каждая
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,  // Иконки справа
                                    children: [
                                      // Иконка избранного (сердечко)
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () async {
                                            // Переключаем состояние избранного
                                            await RecipeManager().toggleFavorite(widget.recipe);
                                            // Обновляем состояние виджета для отображения новой иконки
                                            setState(() {});
                                          },
                                          child: Image.asset(
                                            widget.recipe.isFavorite 
                                                ? 'assets/Icons/heart_red.png' 
                                                : 'assets/Icons/heart_black.png',
                                            width: 24,
                                            height: 24,
                                          )
                                        ),
                                      ),
                                      // Иконка редактирования (карандаш)
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit, color: Color(0xff4d4d4d)),
                                          onPressed: () async {
                                            /*
                                             * ОТКРЫВАЕМ ЭКРАН РЕДАКТИРОВАНИЯ
                                             * Передаем текущий рецепт (widget.recipe) в CreateRecipeScreen
                                             * CreateRecipeScreen поймет, что это режим редактирования
                                             * и заполнит все поля данными из рецепта
                                             * 
                                             * Ждем результат редактирования и обновляем UI если нужно
                                             */
                                            final result = await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => CreateRecipeScreen(recipe: widget.recipe),
                                              ),
                                            );
                                            
                                            /*
                                             * ЕСЛИ РЕЦЕПТ БЫЛ ОБНОВЛЕН (result == true):
                                             * Используем метод _reloadRecipe для обновления данных
                                             * И возвращаем результат чтобы обновить список в RecipeListScreen
                                             */
                                            if (result == true) {
                                              _reloadRecipe();
                                              
                                              // Возвращаемся на список с результатом редактирования
                                              Navigator.pop(context, "edited");  // "edited" = рецепт был изменен
                                            }
                                          },
                                        ),
                                      ),
                                      // Иконка удаления (урна)
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete, color: Color(0xFF4d4d4d)),
                                          onPressed: () async {
                                            /*
                                             * ПОДТВЕРЖДЕНИЕ УДАЛЕНИЯ РЕЦЕПТА
                                             * Показываем диалог подтверждения перед удалением
                                             */
                                            final confirmDelete = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: Text('Удалить рецепт?'),
                                                content: Text('Вы уверены, что хотите удалить рецепт "${widget.recipe.title}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, false),
                                                    child: Text('Отмена'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context, true),
                                                    child: Text('Удалить', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );

                                            /*
                                             * ЕСЛИ ПОЛЬЗОВАТЕЛЬ ПОДТВЕРДИЛ УДАЛЕНИЕ:
                                             * 1. Удаляем рецепт из базы данных
                                             * 2. Показываем сообщение об успехе
                                             * 3. Возвращаемся на предыдущий экран
                                             */
                                            if (confirmDelete == true) {
                                              try {
                                                await RecipeManager().deleteRecipe(widget.recipe.id);
                                                
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Рецепт успешно удален!')),
                                                  );
                                                  
                                                  // Возвращаемся на список рецептов с результатом удаления
                                                  Navigator.pop(context, true);  // true = рецепт был удален
                                                }
                                              } catch (e) {
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('Ошибка при удалении рецепта')),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                color: _borderColor(),  //Передаем цвет контейнера изоходя из статуса проверки ingredient_checker переменной _checkResult
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
                                  onPressed: _checkIngredient,
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
