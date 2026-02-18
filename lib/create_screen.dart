import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'add_ingredient_dialog.dart';
import 'add_step_dialog.dart';
import 'models/ingredient.dart';
import 'models/step.dart';
import 'models/recipe.dart';
import 'domain/recipe_measurement_parser.dart';
import 'recipe_manager.dart';
import 'widgets/recipe_image.dart';

class CreateRecipeScreen extends StatefulWidget {
  /*
   * Параметры экрана:
   * - recipe: если передан, то это режим редактирования
   * - если recipe == null, то это режим создания нового рецепта
   */
  final Recipe? recipe;
  
  const CreateRecipeScreen({super.key, this.recipe});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();    //Вводим контроллер для текстового поля
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final RecipeMeasurementParser _measurementParser = const RecipeMeasurementParser();
  String? recipeImage;
  List<Ingredient> ingredients = [];
  List<RecipeStep> steps = [];


  bool get _canSaveRecipe =>
      _titleController.text.trim().isNotEmpty &&
      ingredients.isNotEmpty &&
      ingredients.every((i) => i.name.trim().isNotEmpty && (_measurementParser.parse(i.measurement)?.baseAmount ?? 0) > 0) &&
      steps.isNotEmpty &&
      steps.every((s) => s.description.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
    /*
     * ЕСЛИ ПЕРЕДАН РЕЦЕПТ - это режим редактирования
     * Заполняем все поля данными из существующего рецепта
     */
    if (widget.recipe != null) {
      final recipe = widget.recipe!;
      _titleController.text = recipe.title;
      _descriptionController.text = recipe.description;
      recipeImage = recipe.imagePath;
      ingredients = List.from(recipe.ingredients);
      steps = List.from(recipe.steps);
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onFormChanged);
    _descriptionController.removeListener(_onFormChanged);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addRecipeImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2048,
    );

    if (pickedFile == null) return;
    final selectedPath = await _openImagePreviewAndConfirm(pickedFile.path);
    if (selectedPath == null) return;
    if (!mounted) return;
    setState(() {
      recipeImage = selectedPath;
    });
  }

  Future<String?> _openImagePreviewAndConfirm(String initialPath) async {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _RecipeImagePreviewScreen(
          initialPath: initialPath,
        ),
      ),
    );
  }

  void _removeRecipeImage() {
    setState(() {
      recipeImage = null;
    });
  }

  Future<void> _editRecipeImage() async {
    if (recipeImage == null) {
      await _addRecipeImage();
      return;
    }

    if (recipeImage!.startsWith('assets/')) {
      await _addRecipeImage();
      return;
    }

    final selectedPath = await _openImagePreviewAndConfirm(recipeImage!);
    if (selectedPath == null) return;
    if (!mounted) return;
    setState(() {
      recipeImage = selectedPath;
    });
  }


  Future<void> _addIngredient() async {
    final Ingredient? ingredient = await showDialog<Ingredient>(    //Возвращаю inredient типа ingredient
      context: context,                                            //Передаю контекст
      barrierDismissible: true,                                   //При нажатии вне диалогового окна закрыть данное окно
      builder: (_) => const AddIngredientDialog(),               //Вызываю диалоговое окно
    );

    if (ingredient != null) {
      setState(() {
        ingredients.add(ingredient);
      });
    }
  }

  Future<void> _editIngredient(int index) async {
    final edited = await showDialog<Ingredient>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddIngredientDialog(
        ingredient: ingredients[index],
      ),
    );

    if (edited != null) {
      setState(() {
        ingredients[index] = edited;
      });
    }
  }

  Future<void> _addStep() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddStepDialog(),
    );

    if (result != null) {
      final stepText = (result['step'] as String).trim();
      if (stepText.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Описание шага не может быть пустым')),
        );
        return;
      }

      final stepNumber = steps.length + 1; 
      final minutes = result['minutes'] as int;
      final seconds = result['seconds'] as int;
      final timeInSeconds = (minutes * 60) + seconds;

      setState(() {
        steps.add(RecipeStep(
          stepNumber: stepNumber,
          description: stepText, 
          timeInSeconds: timeInSeconds,
        ));
      });
    }
  }

  Future<void> _editStep(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddStepDialog(
        step: steps[index],
      ),
    );

    if (result != null) {
      final stepText = (result['step'] as String).trim();
      if (stepText.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Описание шага не может быть пустым')),
        );
        return;
      }

      final minutes = result['minutes'] as int;
      final seconds = result['seconds'] as int;

      setState(() {
        steps[index] = RecipeStep(
          stepNumber: steps[index].stepNumber,
          description: stepText,
          timeInSeconds: (minutes * 60) + seconds,
        );
      });
    }
  }

  Future<void> _saveRecipe() async {
    if (!_canSaveRecipe) return;
    final totalTime = steps.fold<int>(
      0,
          (sum, step) => sum + step.timeInSeconds,
    );

    if (widget.recipe != null) {
      // РЕДАКТИРОВАНИЕ

      final existingRecipe = widget.recipe!;

      existingRecipe.title = _titleController.text.trim();
      existingRecipe.description = _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Без описания';

      existingRecipe.ingredients = ingredients;
      existingRecipe.steps = steps;
      existingRecipe.prepTimeSeconds = totalTime;
      existingRecipe.imagePath = recipeImage ?? '';

      await existingRecipe.save();   // 🔥 ВАЖНО

    } else {
      // СОЗДАНИЕ

      final newRecipe = Recipe(
        id: RecipeManager().getNextId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Без описания',
        ingredients: ingredients,
        prepTimeSeconds: totalTime,
        imagePath: recipeImage ?? '',
        steps: steps,
      );

      await RecipeManager().addRecipe(newRecipe);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),  //Константа - стандартная высота
        child: Container(                                 //Оборачиваем в контейнер чтобы сделать тень
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [                                      //Параметры тени
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),         //Цвет тени и прозрачность
                offset: Offset(0, 3),                            //Смещеине тени по горзионтали 0, по вертикали 2
                blurRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white, // Убираем isCooking
            centerTitle: true,              //Центрирование заголовка
            title: Text(
              widget.recipe != null ? 'Редактирование рецепта' : 'Новый рецепт', // Динамический заголовок
              style: TextStyle(
                color: Color(0xFF165932),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),               //Возвращаем на предыдущий экран при нажатии
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(                                 //Симметричные отступы
          horizontal: MediaQuery.of(context).size.width * 0.0374,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,            //Выравниваем по левому краю
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.01,
                left: MediaQuery.of(context).size.width * 0.07,
                right: MediaQuery.of(context).size.width * 0.07,
                bottom: MediaQuery.of(context).size.height * 0.01,
              ),
              decoration: const BoxDecoration(
              color: Color(0xffeeeeee),
            border: Border(
              bottom: BorderSide(
                color: Color(0xff165932),
                width: 3,
                )
               ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Название рецепта',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xff165932),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),

                  TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      )
                  ),
                ],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // БЛОК ДОБАВЛЕНИЯ ФОТО
            Text(
              'Фото рецепта',
              style: TextStyle(
                color: Color(0xFF165932),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            if (recipeImage == null)
            GestureDetector(
              onTap: _addRecipeImage,
              child: DottedBorder(
                color: const Color(0xFF165932),               //Цвет рамки
                strokeWidth: 2,                                 //Толшина линии
                dashPattern: [20, 20],                           // 6 пикселей — линия, 4 пикселя — пробел
                borderType: BorderType.RRect,                   //Скругленные углы
                radius: const Radius.circular(10),             //Радиус скругления
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  color: Colors.grey[200],
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(
                        'assets/Icons/paste_image_plus.png',
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: MediaQuery.of(context).size.width * 0.15,
                      ),
                      Positioned(
                        bottom: MediaQuery.of(context).size.height * 0.05,
                        child: Text(
                          'Добавить фото рецепта',
                          style: TextStyle(
                            color: Color(0xFF165932),
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            else
              GestureDetector(
                onTap: _editRecipeImage,
                child: Stack(
                  children: [
                    ClipRRect(                                                 //Делим дочерний элемент
                      borderRadius: BorderRadius.circular(10),
                      child: RecipeImage(
                        imagePath: recipeImage!,                                        //Указываем что не меожт быть null благодаря else
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.25,
                        fit: BoxFit.cover,                                   //Заполняем изображеним контейнер образеая лишнее
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.01,
                      left: MediaQuery.of(context).size.height * 0.01,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xAA000000),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.height * 0.01,
                      right: MediaQuery.of(context).size.height * 0.01,
                      child: GestureDetector(                                   //Обработка нажатия на крестик
                        onTap: _removeRecipeImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // ИНГРЕДИЕНТЫ
            Text(
              'Ингредиенты',
              style: TextStyle(
                color: Color(0xFF165932),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            if (ingredients.isEmpty)
              Center(
                child: Text(
                  'нет ингредиентов',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[600]!,
                    width: 3,
                  )
                ),
                child: Column(
                  children: ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 6,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 7), // ← отступ ТОЛЬКО слева
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ingredient.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: MediaQuery.of(context).size.height * 0.001),
                                  Text(
                                    ingredient.measurement,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFF165932)),
                                onPressed: () => _editIngredient(ingredients.indexOf(ingredient)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFF165932)),
                                onPressed: () {
                                  setState(() {
                                    ingredients.remove(ingredient);
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: _addIngredient,
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
                    'Добавить ингредиент',
                    style: TextStyle(
                      color: Color(0xFF165932),
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // ШАГИ ПРИГОТОВЛЕНИЯ
            Text(
              'Шаги приготовления',
              style: TextStyle(
                color: Color(0xFF165932),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            if (steps.isEmpty)
              Center(
                child: Text(
                  'нет шагов приготовления',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.035,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[600]!,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    children: steps.map((step) {
                      final minutes = step.timeInSeconds ~/ 60;
                      final seconds = step.timeInSeconds % 60;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 6,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ШАГ X
                            Text(
                              'Шаг ${step.stepNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 2),

                            // ОПИСАНИЕ ШАГА
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ВРЕМЯ + ИКОНКИ
                            Row(
                              children: [
                                Text(
                                  '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),

                                const Spacer(),

                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: const Color(0xFF165932),
                                  onPressed: () => _editStep(steps.indexOf(step)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: const Color(0xFF165932),
                                  onPressed: () {
                                    setState(() {
                                      steps.remove(step);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),



            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: _addStep,
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
                    'Добавить шаг',
                    style: TextStyle(
                      color: Color(0xFF165932),
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.03),

            // КНОПКА СОХРАНИТЬ
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: _canSaveRecipe ? _saveRecipe : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _canSaveRecipe ? const Color(0xFF2ECC71) : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '\u0421\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c \u0440\u0435\u0446\u0435\u043f\u0442',
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

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          ],
        ),
      ),
    );
  }
}

class _RecipeImagePreviewScreen extends StatefulWidget {
  final String initialPath;

  const _RecipeImagePreviewScreen({
    required this.initialPath,
  });

  @override
  State<_RecipeImagePreviewScreen> createState() =>
      _RecipeImagePreviewScreenState();
}

class _RecipeImagePreviewScreenState extends State<_RecipeImagePreviewScreen> {
  final CropController _cropController = CropController();
  Uint8List? _imageBytes;
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _loadBytes();
  }

  Future<void> _loadBytes() async {
    final bytes = await File(widget.initialPath).readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
    });
  }

  Future<void> _saveCropped(Uint8List croppedData) async {
    final path =
        '${Directory.systemTemp.path}/recipe_crop_${DateTime.now().microsecondsSinceEpoch}.jpg';
    final file = File(path);
    await file.writeAsBytes(croppedData, flush: true);
    if (!mounted) return;
    Navigator.of(context).pop(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: _imageBytes == null
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Crop(
                        image: _imageBytes!,
                        controller: _cropController,
                        maskColor: Colors.black54,
                        baseColor: Colors.black,
                        onCropped: (result) async {
                          if (!mounted) return;
                          setState(() {
                            _isCropping = false;
                          });
                          await _saveCropped(result);
                        },
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isCropping ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.close),
                      label: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_imageBytes == null || _isCropping)
                          ? null
                          : () {
                              setState(() {
                                _isCropping = true;
                              });
                              _cropController.crop();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: _isCropping
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: const Text('Готово'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



