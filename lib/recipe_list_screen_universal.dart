import 'package:flutter/material.dart';
import 'recipe_manager.dart';
import 'models/recipe.dart';
import 'utils/time_formatter.dart';
import 'create_screen.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  final bool isLoggedIn;                                              //Параметр: авторизован или нет
  final VoidCallback? onAddRecipePressed;                            //Параметр что делать при нажатии добавить рецепт

  const RecipeListScreen({
    super.key,
    this.isLoggedIn = true,                                            //Параметр авторизации
    this.onAddRecipePressed,
  });

  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  late List<Recipe> recipes;                                     //Переменная  recipe - список рецептов, который будет заполнен при инициализации

  @override
  void initState() {
    super.initState();
    /*
     * ВАЖНО: initState() вызывается ТОЛЬКО ОДИН РАЗ при создании виджета!
     * Если виджет не уничтожается (как в нашем случае с IndexedStack + GlobalKey),
     * то этот метод больше никогда не вызовется.
     * 
     * ПРОБЛЕМА: Мы загружали рецепты только здесь, поэтому новые рецепты
     * не появлялись после создания - список оставался старым.
     */
    recipes = RecipeManager().getRecipes();                      //Получаем список рецептов из RecipeManager для recipe
  }

  /*
   * НОВЫЙ МЕТОД: Принудительное обновление списка рецептов
   * 
   * ПОЧЕМУ ЭТО РАБОТАЕТ:
   * 1. setState() заставляет Flutter перерисовать виджет
   * 2. RecipeManager().getRecipes() заново читает данные из Hive
   * 3. ListView.builder() видит обновленный список и показывает новые рецепты
   * 
   * БЕЗ ЭТОГО: Новые рецепты сохранялись в Hive, но список не обновлялся
   * до перезапуска приложения (когда initState() вызовется снова)
   */
  void refreshRecipes() {
    setState(() {
      recipes = RecipeManager().getRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFECECEC),                                   //Фон всего экрана
      body: SafeArea(                                            //Основное содержимое экрана body
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.0374, //Отступы размер 0.0374 от ширины симметрично
          ),
          //Вертикальный контейнер для размещения списка
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.026), //Пустое пространство сверху
              //Занимаем все оставшееся пространство внутри контейнера
              Expanded(
                child: ListView.builder(                //Прокручиваемый список
                  itemCount: recipes.length,            //Берем количество эелементов из менеджера рецептов
                  itemBuilder: (context, index) {       //Создаем список, на вход берем контекст экрана и индексы рецептов
                    final recipe = recipes[index];     // recipe - рецепт по списку из мэнеджера
                    return InkWell(                                          //Оборачиваем в InkWell для обработки нажатий с визуальным откликом
                      onTap: () {                                            //При нажатии открываем детальный экран рецепта
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecipeDetailScreen(
                              recipe: recipe,
                              isLoggedIn: widget.isLoggedIn,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(10),               //Скругление для ripple эффекта
                      child: Container(                                         // Возвращаем контейнеры для каждого элемента по индексу index
                        margin: EdgeInsets.only(                                //Добавим нижний отсуп после каждого отдельного контейнера
                          bottom: MediaQuery.of(context).size.height * 0.017,   //Отступ 0.017 от высоты экрана
                        ),
                        width: MediaQuery.of(context).size.width * 0.925,        //Размеры контейнера
                        height: MediaQuery.of(context).size.height * 0.147,
                        decoration: BoxDecoration(                               //Закгругление контейнеров
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,                                    //Белый фон контейнера
                        ),
                        child: Row(                                               //Создаем ряд в контейнере с двумя элементами Expanded для изображения
                          children: [                                             //и Expanded - Column для текста с иконкой и временм
                            Expanded(
                              flex: 20,
                              child: ClipRRect(                                   //Обрезаем изобраежние также как и сам контейнер чтобы небыло отсрых уголов
                                borderRadius: BorderRadius.only(                  //only - значит нужно конкретно указать углы для скругления, в отличии от circular
                                  topLeft: Radius.circular(10),                   //Верхний левый
                                  bottomLeft: Radius.circular(10),                //Левый нижний
                                ),
                                child: Image.asset(                                 //Загружаем изображение
                                  recipe.imagePath,                                 //Берем изображение по пути
                                  fit: BoxFit.cover,                                //Заполняем весь контейнер обрезаем то что не влазит
                                  height: double.infinity,                          //Занимаем всю высоту  контейнера
                                ),
                              ),
                            ),

                            SizedBox(width: MediaQuery.of(context).size.width * 0.03), //Отступ между изображением и текстом

                            // Текстовая часть
                            //Железобетонно ставим все элементы
                            Expanded(
                              flex: 33,
                              child: Stack(
                                children: [
                                  Positioned(                                                 //Точно позиционируем дочерние элементы в стеке
                                    top: MediaQuery.of(context).size.height * 0.025,          //Отступ сверху
                                    left: 0,
                                    right: 0,
                                    child: Padding(                                            //Добавление внутренних отступов
                                      padding: const EdgeInsets.only(right: 4),               //Отступ только справа 12 пикселей
                                      child: Text(
                                        recipe.title,
                                        maxLines: 2,                                            //Максимальное количество строк
                                        overflow: TextOverflow.ellipsis,                        //Если текст не помещается - добавить многоточие
                                        style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width * 0.06,
                                      fontWeight: FontWeight.w600,
                                      height: 1.0,
                                      leadingDistribution: TextLeadingDistribution.even,     //Распределение свообдного места между строками
                                    ),
                                    ),
                                    ),
                                  ),

                                  Positioned(                                                     //Второй элемент
                                    bottom: MediaQuery.of(context).size.height * 0.025,           //Отступ снизу
                                    left: 0,
                                    child: Row(
                                      children: [
                                        Image.asset('assets/Icons/clock.png', width: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatTime(recipe.prepTimeSeconds),
                                          style: TextStyle(
                                            color: Color(0xFF2ECC71),
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      //Кнопка внизу экрана, появляется если пользователь автризирован
      //Используем Scaffold.flatingActionButton и flatingActionButtonLocation потому что кнопка только одна
      //Если бы кнопок было бы несколько пришлось бы использовать Positioned
      floatingActionButton: widget.isLoggedIn ? Container(
        width: 60,
        height: 60,
        child: FloatingActionButton(
          onPressed: widget.onAddRecipePressed ?? () {
            //Если callback не передан, используем навигацию по умолчанию
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateRecipeScreen(),
              ),
            );
          },
          backgroundColor: Color(0xFF2ECC71),
          child: Icon(Icons.add, color: Colors.white), //Кнопка с плюсом
          shape: CircleBorder(),                       //Полностью круглая
        ),
      )
          : null,                                                                //Если не авторизован - кнопка не отображается
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,  //Кнопка справа

    );
  }
}