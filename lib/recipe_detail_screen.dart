import 'dart:async';
import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../utils/time_formatter.dart';
import '../models/comment.dart';
import '../models/ingredient_check_result.dart';
import '../repositories/fridge_repository.dart';
import '../repositories/history_repository.dart';
import '../services/recipe_availability_service.dart';
import '../models/history/recipe_history_entry.dart';
import '../widgets/recipe_image.dart';
import 'recipe_manager.dart';
import 'create_screen.dart';

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
  final RecipeAvailabilityService _availabilityService =
      const RecipeAvailabilityService();
  bool isCooking = false;
  bool isFavorite = false;
  int remainingTime = 0;
  Timer? timer;
  List<bool> stepCompleted = [];
  String? selectedCommentImage;
  bool _consumeOnFinish = true;
  RecipeAvailabilityResult? _lastAvailabilityResult;

  @override
  void initState() {
    super.initState();
    stepCompleted = List.generate(widget.recipe.steps.length, (index) => false);
  }

  void _reloadRecipe() {
    final updatedRecipe = RecipeManager().getRecipes().firstWhere(
      (r) => r.id == widget.recipe.id,
    );

    setState(() {
      widget.recipe.title = updatedRecipe.title;
      widget.recipe.description = updatedRecipe.description;
      widget.recipe.ingredients = updatedRecipe.ingredients;
      widget.recipe.steps = updatedRecipe.steps;
      widget.recipe.prepTimeSeconds = updatedRecipe.prepTimeSeconds;
      widget.recipe.imagePath = updatedRecipe.imagePath;
      widget.recipe.isFavorite = updatedRecipe.isFavorite;

      stepCompleted = List.generate(
        updatedRecipe.steps.length,
        (index) => false,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> startCooking() async {
    final fridgeItems = FridgeRepository.getItems();
    final availability = _availabilityService.checkAndBuildConsumption(
      recipeIngredients: widget.recipe.ingredients,
      fridgeItems: fridgeItems,
    );

    _lastAvailabilityResult = availability;
    _checkResult = availability.hasAllIngredients
        ? IngredientCheckResult.success
        : IngredientCheckResult.failure;

    if (!availability.hasAllIngredients) {
      final proceedWithoutConsumption = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Ингредиентов недостаточно',
            style: TextStyle(
              color: Color(0xFF165932),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Можно продолжить, но ингредиенты не будут списаны из холодильника, и запись не попадет в историю.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF165932),
              ),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF165932),
                foregroundColor: Colors.white,
              ),
              child: const Text('Продолжить'),
            ),
          ],
        ),
      );

      if (proceedWithoutConsumption != true) {
        return;
      }
      _consumeOnFinish = false;
    } else {
      _consumeOnFinish = true;
    }

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

  Future<void> finishCooking() async {
    if (_consumeOnFinish &&
        _lastAvailabilityResult?.hasAllIngredients == true) {
      await FridgeRepository.saveItems(_lastAvailabilityResult!.updatedItems);

      final entry = RecipeHistoryEntry(
        id: '${DateTime.now().microsecondsSinceEpoch}_${widget.recipe.id}',
        createdAtMillis: DateTime.now().millisecondsSinceEpoch,
        recipeId: widget.recipe.id,
        recipeTitle: widget.recipe.title,
        recipeImagePath: widget.recipe.imagePath,
        consumedItems: _lastAvailabilityResult!.consumedSnapshot,
      );

      await HistoryRepository.saveEntry(entry);
    }

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

  Widget _buildComment(Comment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

                  Text(
                    comment.text,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: MediaQuery.of(context).size.width * 0.035,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    softWrap: true,
                  ),

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

  void _openCommentInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(
            bottom: bottomInset + (MediaQuery.of(context).size.height * 0.01),
            top: MediaQuery.of(context).size.height * 0.015,
            left: MediaQuery.of(context).size.width * 0.02,
            right: MediaQuery.of(context).size.width * 0.02,
          ),
          child: SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.14,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xff165932), width: 3),
              ),
              child: Stack(
                children: [
                  TextField(
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
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
          ),
        );
      },
    );
  }

  IngredientCheckResult _checkResult = IngredientCheckResult.idle;

  Color _borderColor() {
    switch (_checkResult) {
      case IngredientCheckResult.success:
        return Color(0xff2ecc71);
      case IngredientCheckResult.failure:
        return Colors.red;
      case IngredientCheckResult.idle:
        return Color(0xffa0a0a0);
    }
  }

  void _checkIngredient() {
    final fridgeItems = FridgeRepository.getItems();
    final availability = _availabilityService.checkAndBuildConsumption(
      recipeIngredients: widget.recipe.ingredients,
      fridgeItems: fridgeItems,
    );
    _lastAvailabilityResult = availability;

    setState(() {
      _checkResult = availability.hasAllIngredients
          ? IngredientCheckResult.success
          : IngredientCheckResult.failure;
    });
  }

  Future<bool> _confirmExitWithoutFinishing() async {
    if (!isCooking) return true;

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Выйти без завершения?',
          style: TextStyle(
            color: Color(0xFF165932),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Рецепт еще не завершен. Если выйти сейчас, прогресс будет сброшен: ингредиенты не спишутся, а запись не попадет в историю.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF165932),
            ),
            child: const Text('Остаться'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    return shouldExit == true;
  }

  Future<void> _onBackPressed() async {
    final shouldExit = await _confirmExitWithoutFinishing();
    if (!mounted || !shouldExit) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _onBackPressed();
      },
      child: Scaffold(
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
                      color: Colors.black.withValues(alpha: 0.2),
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
              onPressed: _onBackPressed,
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.0374,
                        vertical: MediaQuery.of(context).size.height * 0.02,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: widget.isLoggedIn ? 6 : 9,
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

                              if (widget.isLoggedIn)
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () async {
                                            await RecipeManager().toggleFavorite(
                                              widget.recipe,
                                            );

                                            setState(() {});
                                          },
                                          child: Image.asset(
                                            widget.recipe.isFavorite
                                                ? 'assets/Icons/heart_red.png'
                                                : 'assets/Icons/heart_black.png',
                                            width: 24,
                                            height: 24,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Color(0xff4d4d4d),
                                          ),
                                          onPressed: () async {
                                            final result =
                                                await Navigator.push<bool>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        CreateRecipeScreen(
                                                          recipe: widget.recipe,
                                                        ),
                                                  ),
                                                );
                                            if (!context.mounted) return;

                                            if (result == true) {
                                              _reloadRecipe();

                                              Navigator.pop(context, "edited");
                                            }
                                          },
                                        ),
                                      ),

                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color(0xFF4d4d4d),
                                          ),
                                          onPressed: () async {
                                            final confirmDelete =
                                                await showDialog<bool>(
                                                  context: context,
                                                  barrierDismissible: true,
                                                  builder: (ctx) => AlertDialog(
                                                    backgroundColor: Colors.white,
                                                    title: const Text(
                                                      'Удалить рецепт?',
                                                      style: TextStyle(
                                                        color: Color(0xFF165932),
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    content: Text(
                                                      'Вы уверены, что хотите удалить рецепт "${widget.recipe.title}"?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(false),
                                                        style: TextButton.styleFrom(
                                                          foregroundColor:
                                                              const Color(
                                                                0xFF165932,
                                                              ),
                                                        ),
                                                        child: const Text('Отмена'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(true),
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFFD32F2F,
                                                                  ),
                                                              foregroundColor:
                                                                  Colors.white,
                                                            ),
                                                        child: const Text(
                                                          'Удалить',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                            if (!context.mounted) return;

                                            if (confirmDelete == true) {
                                              try {
                                                await RecipeManager()
                                                    .deleteRecipe(
                                                      widget.recipe.id,
                                                    );

                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Рецепт успешно удален!',
                                                    ),
                                                  ),
                                                );

                                                Navigator.pop(context, true);
                                              } catch (e) {
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Ошибка при удалении рецепта',
                                                    ),
                                                  ),
                                                );
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

                          Container(
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: RecipeImage(
                                imagePath: widget.recipe.imagePath,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

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
                                color: _borderColor(),
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

                          if (_checkResult == IngredientCheckResult.failure &&
                              _lastAvailabilityResult != null &&
                              _lastAvailabilityResult!.missingNames.isNotEmpty) ...[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.012,
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFFFF5F5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFFD32F2F),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Не хватает в холодильнике:',
                                    style: TextStyle(
                                      color: Color(0xFFD32F2F),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.036,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.008,
                                  ),
                                  ..._lastAvailabilityResult!.missingNames.map((
                                    missingName,
                                  ) {
                                    return Padding(
                                      padding: EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '• ',
                                            style: TextStyle(
                                              color: Color(0xFFD32F2F),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              missingName,
                                              style: TextStyle(
                                                color: Color(0xFF4D4D4D),
                                                fontSize:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    0.035,
                                                fontFamily: 'Roboto',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

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
                            height: MediaQuery.of(context).size.height * 0.015,
                          ),

                          if (widget.isLoggedIn)
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: ElevatedButton(
                                  onPressed: isCooking ? null : startCooking,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCooking
                                        ? Colors.grey
                                        : Color(0xFF165932),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Начать готовить',
                                    style: TextStyle(
                                      color: Colors.white,
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

                          if (widget.isLoggedIn)
                            Center(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: ElevatedButton(
                                  onPressed: isCooking ? finishCooking : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isCooking
                                        ? Color(0xFF2ECC71)
                                        : Colors.grey,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    'Закончить готовить',
                                    style: TextStyle(
                                      color: Colors.white,
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

                    if (widget.isLoggedIn)
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),
                            ...comments.map(
                              (comment) => _buildComment(comment),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),

                            Padding(
                              padding: EdgeInsets.only(bottom: 15),
                              child: GestureDetector(
                                onTap: _openCommentInput,
                                child: Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Color(0xff165932),
                                      width: 3,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.04,
                                          right:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.12,
                                          top:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.02,
                                          bottom:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.02,
                                        ),
                                        child: Text(
                                          'Оставить комментарий',
                                          style: TextStyle(
                                            color: Color(0xffc2c2c2),
                                            fontSize:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.037,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top:
                                            MediaQuery.of(context).size.height *
                                            0.012,
                                        right:
                                            MediaQuery.of(context).size.width *
                                            0.02,
                                        child: Image.asset(
                                          'assets/Icons/paste_image.png',
                                          width:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.06,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
    )
    );
  }
}
