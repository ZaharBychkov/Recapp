import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'add_ingredient_dialog.dart';
import '../models/ingredient.dart';
import 'add_step_dialog.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({super.key});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final TextEditingController _titleController = TextEditingController();    //Вводим контроллер для текстового поля
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
      recipeImage = 'assets/Images/burger_with_two_cutlets.png';
    });
    print("Добавить фото рецепта");
  }

  void _removeRecipeImage() {
    setState(() {
      recipeImage = null;
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
        ingredients.add('${ingredient.name} - ${ingredient.measurement}');
      });
    }
  }

  Future<void> _addStep() async {
    final result = await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const AddStepDialog(),
      );

    if (result != null) {
      print(result);
    }
  }

  void _saveRecipe() {
    // Заглушка для сохранения рецепта
    print("Сохранить рецепт");
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
                color: Colors.black.withOpacity(0.2),         //Цвет тени и прозрачность
                offset: Offset(0, 3),                            //Смещеине тени по горзионтали 0, по вертикали 2
                blurRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white, // Убираем isCooking
            centerTitle: true,              //Центрирование заголовка
            title: Text(
              'Новый рецепт', // Меняем текст заголовка
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
        radius: const Radius.circular(10),             //Радиус скргления
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
              Stack(
                children: [
                  ClipRRect(                                                 //Делим дочерний элемент
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      recipeImage!,                                        //Указываем что не меожт быть null благодаря else
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.25,
                      fit: BoxFit.cover,                                   //Заполняем изображеним контейнер образеая лишнее
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.01,
                    right: MediaQuery.of(context).size.height * 0.01,
                    child: GestureDetector(                                   //Обработка нажатия на крестик
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