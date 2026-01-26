import 'package:flutter/material.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();
  String? recipeImage;
  List<String> ingredients = [];
  List<String> steps = [];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _addRecipeImage() {
    // Заглушка для добавления изображения
    setState(() {
      recipeImage = 'assets/Images/salmon_in_teriyaki_sauce.png';
    });
    print("Добавить фото рецепта");
  }

  void _removeRecipeImage() {
    setState(() {
      recipeImage = null;
    });
  }

  void _addIngredient() {
    // Заглушка для добавления ингредиента
    print("Добавить ингредиент");
  }

  void _addStep() {
    // Заглушка для добавления шага
    print("Добавить шаг");
  }

  void _saveRecipe() {
    // Заглушка для сохранения рецепта
    print("Сохранить рецепт");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Новый рецепт',
          style: TextStyle(
            color: Color(0xFF165932),
            fontWeight: FontWeight.w600,
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.0374,
          vertical: MediaQuery.of(context).size.height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ПОЛЕ ВВОДА НАЗВАНИЯ
            Text(
              'Название рецепта',
              style: TextStyle(
                color: Color(0xFF165932),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Введите название',
                hintStyle: TextStyle(
                  color: Color(0xffc2c2c2),
                  fontFamily: 'Roboto',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xffa0a0a0), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xffa0a0a0), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF165932), width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Color(0xffa0a0a0),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF165932),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 35,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Добавить фото рецепта',
                        style: TextStyle(
                          color: Color(0xFF165932),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      recipeImage!,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

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
              ),

            SizedBox(height: MediaQuery.of(context).size.height * 0.01),

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
                  onPressed: _saveRecipe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF165932),
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Сохранить рецепт',
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