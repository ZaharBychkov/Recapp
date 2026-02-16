import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'add_ingredient_dialog.dart';
import 'add_step_dialog.dart';
import 'models/ingredient.dart';
import 'models/step.dart';
import 'models/recipe.dart';
import 'recipe_manager.dart';

class CreateRecipeScreen extends StatefulWidget {
  /*
   * РџР°СЂР°РјРµС‚СЂС‹ СЌРєСЂР°РЅР°:
   * - recipe: РµСЃР»Рё РїРµСЂРµРґР°РЅ, С‚Рѕ СЌС‚Рѕ СЂРµР¶РёРј СЂРµРґР°РєС‚РёСЂРѕРІР°РЅРёСЏ
   * - РµСЃР»Рё recipe == null, С‚Рѕ СЌС‚Рѕ СЂРµР¶РёРј СЃРѕР·РґР°РЅРёСЏ РЅРѕРІРѕРіРѕ СЂРµС†РµРїС‚Р°
   */
  final Recipe? recipe;
  
  const CreateRecipeScreen({super.key, this.recipe});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();    //Р’РІРѕРґРёРј РєРѕРЅС‚СЂРѕР»Р»РµСЂ РґР»СЏ С‚РµРєСЃС‚РѕРІРѕРіРѕ РїРѕР»СЏ
  final TextEditingController _descriptionController = TextEditingController();
  String? recipeImage;
  List<Ingredient> ingredients = [];
  List<RecipeStep> steps = [];


  bool get _canSaveRecipe =>
      ingredients.isNotEmpty && steps.isNotEmpty;

  @override
  void initState() {
    super.initState();
    /*
     * Р•РЎР›Р РџР•Р Р•Р”РђРќ Р Р•Р¦Р•РџРў - СЌС‚Рѕ СЂРµР¶РёРј СЂРµРґР°РєС‚РёСЂРѕРІР°РЅРёСЏ
     * Р—Р°РїРѕР»РЅСЏРµРј РІСЃРµ РїРѕР»СЏ РґР°РЅРЅС‹РјРё РёР· СЃСѓС‰РµСЃС‚РІСѓСЋС‰РµРіРѕ СЂРµС†РµРїС‚Р°
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
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addRecipeImage() {
    // Р—Р°РіР»СѓС€РєР° РґР»СЏ РґРѕР±Р°РІР»РµРЅРёСЏ РёР·РѕР±СЂР°Р¶РµРЅРёСЏ
    setState(() {
      recipeImage = 'assets/Images/burger_with_two_cutlets.png';
    });
    debugPrint("Р”РѕР±Р°РІРёС‚СЊ С„РѕС‚Рѕ СЂРµС†РµРїС‚Р°");
  }

  void _removeRecipeImage() {
    setState(() {
      recipeImage = null;
    });
  }


  Future<void> _addIngredient() async {
    final Ingredient? ingredient = await showDialog<Ingredient>(    //Р’РѕР·РІСЂР°С‰Р°СЋ inredient С‚РёРїР° ingredient
      context: context,                                            //РџРµСЂРµРґР°СЋ РєРѕРЅС‚РµРєСЃС‚
      barrierDismissible: true,                                   //РџСЂРё РЅР°Р¶Р°С‚РёРё РІРЅРµ РґРёР°Р»РѕРіРѕРІРѕРіРѕ РѕРєРЅР° Р·Р°РєСЂС‹С‚СЊ РґР°РЅРЅРѕРµ РѕРєРЅРѕ
      builder: (_) => const AddIngredientDialog(),               //Р’С‹Р·С‹РІР°СЋ РґРёР°Р»РѕРіРѕРІРѕРµ РѕРєРЅРѕ
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
      final stepNumber = steps.length + 1; 
      final minutes = result['minutes'] as int;
      final seconds = result['seconds'] as int;
      final timeInSeconds = (minutes * 60) + seconds;

      setState(() {
        steps.add(RecipeStep(
          stepNumber: stepNumber,
          description: result['step'] as String, 
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
      final minutes = result['minutes'] as int;
      final seconds = result['seconds'] as int;

      setState(() {
        steps[index] = RecipeStep(
          stepNumber: steps[index].stepNumber,
          description: result['step'],
          timeInSeconds: (minutes * 60) + seconds,
        );
      });
    }
  }

  Future<void> _saveRecipe() async {
    final totalTime = steps.fold<int>(
      0,
          (sum, step) => sum + step.timeInSeconds,
    );

    if (widget.recipe != null) {
      // Р Р•Р”РђРљРўРР РћР’РђРќРР•

      final existingRecipe = widget.recipe!;

      existingRecipe.title = _titleController.text.trim();
      existingRecipe.description =
      _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : 'Р‘РµР· РѕРїРёСЃР°РЅРёСЏ';

      existingRecipe.ingredients = ingredients;
      existingRecipe.steps = steps;
      existingRecipe.prepTimeSeconds = totalTime;
      existingRecipe.imagePath =
          recipeImage ?? 'assets/Images/burger_with_two_cutlets.png';

      await existingRecipe.save();   // рџ”Ґ Р’РђР–РќРћ

    } else {
      // РЎРћР—Р”РђРќРР•

      final newRecipe = Recipe(
        id: RecipeManager().getNextId(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : 'Р‘РµР· РѕРїРёСЃР°РЅРёСЏ',
        ingredients: ingredients,
        prepTimeSeconds: totalTime,
        imagePath:
        recipeImage ?? 'assets/Images/burger_with_two_cutlets.png',
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
        preferredSize: Size.fromHeight(kToolbarHeight),  //РљРѕРЅСЃС‚Р°РЅС‚Р° - СЃС‚Р°РЅРґР°СЂС‚РЅР°СЏ РІС‹СЃРѕС‚Р°
        child: Container(                                 //РћР±РѕСЂР°С‡РёРІР°РµРј РІ РєРѕРЅС‚РµР№РЅРµСЂ С‡С‚РѕР±С‹ СЃРґРµР»Р°С‚СЊ С‚РµРЅСЊ
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [                                      //РџР°СЂР°РјРµС‚СЂС‹ С‚РµРЅРё
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),         //Р¦РІРµС‚ С‚РµРЅРё Рё РїСЂРѕР·СЂР°С‡РЅРѕСЃС‚СЊ
                offset: Offset(0, 3),                            //РЎРјРµС‰РµРёРЅРµ С‚РµРЅРё РїРѕ РіРѕСЂР·РёРѕРЅС‚Р°Р»Рё 0, РїРѕ РІРµСЂС‚РёРєР°Р»Рё 2
                blurRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white, // РЈР±РёСЂР°РµРј isCooking
            centerTitle: true,              //Р¦РµРЅС‚СЂРёСЂРѕРІР°РЅРёРµ Р·Р°РіРѕР»РѕРІРєР°
            title: Text(
              widget.recipe != null ? 'Р РµРґР°РєС‚РёСЂРѕРІР°РЅРёРµ СЂРµС†РµРїС‚Р°' : 'РќРѕРІС‹Р№ СЂРµС†РµРїС‚', // Р”РёРЅР°РјРёС‡РµСЃРєРёР№ Р·Р°РіРѕР»РѕРІРѕРє
              style: TextStyle(
                color: Color(0xFF165932),
                fontWeight: FontWeight.w600,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),               //Р’РѕР·РІСЂР°С‰Р°РµРј РЅР° РїСЂРµРґС‹РґСѓС‰РёР№ СЌРєСЂР°РЅ РїСЂРё РЅР°Р¶Р°С‚РёРё
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(                                 //РЎРёРјРјРµС‚СЂРёС‡РЅС‹Рµ РѕС‚СЃС‚СѓРїС‹
          horizontal: MediaQuery.of(context).size.width * 0.0374,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,            //Р’С‹СЂР°РІРЅРёРІР°РµРј РїРѕ Р»РµРІРѕРјСѓ РєСЂР°СЋ
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
                    'РќР°Р·РІР°РЅРёРµ СЂРµС†РµРїС‚Р°',
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

            // Р‘Р›РћРљ Р”РћР‘РђР’Р›Р•РќРРЇ Р¤РћРўРћ
            Text(
              'Р¤РѕС‚Рѕ СЂРµС†РµРїС‚Р°',
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
                color: const Color(0xFF165932),               //Р¦РІРµС‚ СЂР°РјРєРё
                strokeWidth: 2,                                 //РўРѕР»С€РёРЅР° Р»РёРЅРёРё
                dashPattern: [20, 20],                           // 6 РїРёРєСЃРµР»РµР№ вЂ” Р»РёРЅРёСЏ, 4 РїРёРєСЃРµР»СЏ вЂ” РїСЂРѕР±РµР»
                borderType: BorderType.RRect,                   //РЎРєСЂСѓРіР»РµРЅРЅС‹Рµ СѓРіР»С‹
                radius: const Radius.circular(10),             //Р Р°РґРёСѓСЃ СЃРєСЂРіР»РµРЅРёСЏ
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
                          'Р”РѕР±Р°РІРёС‚СЊ С„РѕС‚Рѕ СЂРµС†РµРїС‚Р°',
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
              Stack(
                children: [
                  ClipRRect(                                                 //Р”РµР»РёРј РґРѕС‡РµСЂРЅРёР№ СЌР»РµРјРµРЅС‚
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      recipeImage!,                                        //РЈРєР°Р·С‹РІР°РµРј С‡С‚Рѕ РЅРµ РјРµРѕР¶С‚ Р±С‹С‚СЊ null Р±Р»Р°РіРѕРґР°СЂСЏ else
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      fit: BoxFit.cover,                                   //Р—Р°РїРѕР»РЅСЏРµРј РёР·РѕР±СЂР°Р¶РµРЅРёРј РєРѕРЅС‚РµР№РЅРµСЂ РѕР±СЂР°Р·РµР°СЏ Р»РёС€РЅРµРµ
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.01,
                    right: MediaQuery.of(context).size.height * 0.01,
                    child: GestureDetector(                                   //РћР±СЂР°Р±РѕС‚РєР° РЅР°Р¶Р°С‚РёСЏ РЅР° РєСЂРµСЃС‚РёРє
                      onTap: _removeRecipeImage,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.02),

            // РРќР“Р Р•Р”РР•РќРўР«
            Text(
              'РРЅРіСЂРµРґРёРµРЅС‚С‹',
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
                  'РЅРµС‚ РёРЅРіСЂРµРґРёРµРЅС‚РѕРІ',
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
                              padding: const EdgeInsets.only(left: 7), // в†ђ РѕС‚СЃС‚СѓРї РўРћР›Р¬РљРћ СЃР»РµРІР°
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
                    'Р”РѕР±Р°РІРёС‚СЊ РёРЅРіСЂРµРґРёРµРЅС‚',
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

            // РЁРђР“Р РџР РР“РћРўРћР’Р›Р•РќРРЇ
            Text(
              'РЁР°РіРё РїСЂРёРіРѕС‚РѕРІР»РµРЅРёСЏ',
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
                  'РЅРµС‚ С€Р°РіРѕРІ РїСЂРёРіРѕС‚РѕРІР»РµРЅРёСЏ',
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
                            // РЁРђР“ X
                            Text(
                              'РЁР°Рі ${step.stepNumber}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 2),

                            // РћРџРРЎРђРќРР• РЁРђР“Рђ
                            Text(
                              step.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Р’Р Р•РњРЇ + РРљРћРќРљР
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
                    'Р”РѕР±Р°РІРёС‚СЊ С€Р°Рі',
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

            // РљРќРћРџРљРђ РЎРћРҐР РђРќРРўР¬
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: ElevatedButton(
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSaveRecipe ? const Color(0xff165932) : Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'РЎРѕС…СЂР°РЅРёС‚СЊ СЂРµС†РµРїС‚',
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

