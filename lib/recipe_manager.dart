import 'models/recipe.dart';
import 'models/ingredient.dart';
import 'models/step.dart';

class RecipeManager {
  List<Recipe> getRecipes() {
    return [
      Recipe(
        1,
        "Лосось в соусе терияки",
        "Нежное филе лосося, приготовленное в ароматном соусе терияки с нотками имбиря и чеснока.",
        [
          Ingredient(name: "Соевый соус", measurement: "8 ст. ложек"),
          Ingredient(name: "Вода", measurement: "6 ст. ложек"),
          Ingredient(name: "Мед", measurement: "3 ст. ложки"),
          Ingredient(name: "Коричневый сахар", measurement: "2 ст. ложки"),
          Ingredient(name: "Чеснок", measurement: "3 зубчика"),
          Ingredient(name: "Тертый свежий имбирь", measurement: "1 ст. ложка"),
          Ingredient(name: "Лимонный сок", measurement: "1.5 ст. ложки"),
          Ingredient(name: "Кукурузный крахмал", measurement: "1 ст. ложка"),
          Ingredient(name: "Растительное масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Филе лосося", measurement: "680 г"),
          Ingredient(name: "Кунжут", measurement: "по вкусу"),
        ],
        45 * 60,
        "assets/Images/salmon_in_teriyaki_sauce.png",
        [
          Step(
            stepNumber: 1,
            description: "В маленькой кастрюле соедините соевый соус, 6 столовых ложек воды, мёд, сахар, измельчённый чеснок, имбирь и лимонный сок.",
            timeInSeconds: 6 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Поставьте на средний огонь и, помешивая, доведите до лёгкого кипения.",
            timeInSeconds: 7 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Смешайте оставшуюся воду с крахмалом. Добавьте в кастрюлю и перемешайте.",
            timeInSeconds: 6 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Готовьте, непрерывно помешивая венчиком, 1 минуту. Снимите с огня и немного остудите.",
            timeInSeconds: 1 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Смажьте форму маслом и выложите туда рыбу. Полейте её соусом.",
            timeInSeconds: 6 * 60,
          ),
        ],
      ),
      Recipe(
        2,
        "Бургер с двумя котлетами",
        "Сочный двойной бургер с хрустящими котлетами и свежими овощами.",
        [
          Ingredient(name: "Булочка для бургера", measurement: "1 шт."),
          Ingredient(name: "Говяжья котлета", measurement: "2 шт. (по 100 г)"),
          Ingredient(name: "Салат", measurement: "50 г"),
          Ingredient(name: "Помидор", measurement: "1 шт."),
          Ingredient(name: "Лук", measurement: "1/2 шт."),
          Ingredient(name: "Сыр чеддер", measurement: "2 ломтика"),
          Ingredient(name: "Кетчуп", measurement: "1 ст. ложка"),
          Ingredient(name: "Горчица", measurement: "1 ч. ложка"),
          Ingredient(name: "Масло для жарки", measurement: "1 ст. ложка"),
        ],
        60 * 60,
        "assets/Images/burger_with_two_cutlets.png",
        [
          Step(
            stepNumber: 1,
            description: "Разогрейте сковороду на среднем огне и слегка смажьте маслом.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Обжарьте котлеты по 4 минуты с каждой стороны до золотистой корочки.",
            timeInSeconds: 8 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Добавьте ломтики сыра на котлеты за 1 минуту до готовности.",
            timeInSeconds: 1 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Поджарьте булочки на сухой сковороде до хруста.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Соберите бургер: булочка, кетчуп, котлеты, овощи, вторая булочка.",
            timeInSeconds: 3 * 60,
          ),
        ],
      ),
      Recipe(
        3,
        "Стейк из говядины по-грузински с кукурузой",
        "Классический грузинский стейк с пряными специями и сливочным соусом.",
        [
          Ingredient(name: "Говядина", measurement: "400 г"),
          Ingredient(name: "Лук", measurement: "1 шт."),
          Ingredient(name: "Чеснок", measurement: "2 зубчика"),
          Ingredient(name: "Сливочное масло", measurement: "50 г"),
          Ingredient(name: "Сливки", measurement: "100 мл"),
          Ingredient(name: "Хмели-сунели", measurement: "1 ч. ложка"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
          Ingredient(name: "Перец", measurement: "по вкусу"),
          Ingredient(name: "Масло для жарки", measurement: "2 ст. ложки"),
        ],
        75 * 60,
        "assets/Images/georgian_beef_steak.png",
        [
          Step(
            stepNumber: 1,
            description: "Нарежьте мясо на толстые стейки толщиной 2-3 см.",
            timeInSeconds: 5 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Посолите, поперчите и посыпьте хмели-сунели.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Разогрейте сковороду с маслом на сильном огне.",
            timeInSeconds: 3 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Обжарьте стейки по 4 минуты с каждой стороны.",
            timeInSeconds: 8 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Добавьте сливочное масло, чеснок и лук. Полейте стейки соусом.",
            timeInSeconds: 5 * 60,
          ),
        ],
      ),
      Recipe(
        4,
        "Пицца Маргарита домашняя",
        "Традиционная итальянская пицца с томатами, моцареллой и базиликом.",
        [
          Ingredient(name: "Тесто для пиццы", measurement: "200 г"),
          Ingredient(name: "Моцарелла", measurement: "150 г"),
          Ingredient(name: "Помидоры", measurement: "100 г"),
          Ingredient(name: "Базилик", measurement: "5-6 листьев"),
          Ingredient(name: "Оливковое масло", measurement: "1 ст. ложка"),
          Ingredient(name: "Соль", measurement: "щепотка"),
          Ingredient(name: "Томатный соус", measurement: "3 ст. ложки"),
        ],
        25 * 60,
        "assets/Images/homemade_pizza_margarita.png",
        [
          Step(
            stepNumber: 1,
            description: "Разогрейте духовку до 220°C.",
            timeInSeconds: 10 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Раскатайте тесто в круглую форму.",
            timeInSeconds: 5 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Смажьте тесто томатным соусом и посыпьте тёртой моцареллой.",
            timeInSeconds: 3 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Выпекайте в духовке 12 минут до золотистой корочки.",
            timeInSeconds: 12 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Выньте из духовки и украсьте свежим базиликом.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
      Recipe(
        5,
        "Паста с морепродуктами",
        "Ароматная паста с креветками, мидиями и сливочным соусом.",
        [
          Ingredient(name: "Спагетти", measurement: "200 г"),
          Ingredient(name: "Креветки", measurement: "150 г"),
          Ingredient(name: "Мидии", measurement: "100 г"),
          Ingredient(name: "Сливки", measurement: "150 мл"),
          Ingredient(name: "Чеснок", measurement: "2 зубчика"),
          Ingredient(name: "Петрушка", measurement: "1 ст. ложка"),
          Ingredient(name: "Оливковое масло", measurement: "2 ст. ложки"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
          Ingredient(name: "Перец", measurement: "по вкусу"),
        ],
        25 * 60,
        "assets/Images/pasta_with_seafood.png",
        [
          Step(
            stepNumber: 1,
            description: "Отварите спагетти в подсоленной воде до состояния al dente.",
            timeInSeconds: 10 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Разогрейте сковороду с оливковым маслом.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Обжарьте чеснок до аромата, добавьте морепродукты.",
            timeInSeconds: 5 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Влейте сливки, посолите, поперчите. Протушите 3 минуты.",
            timeInSeconds: 3 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Добавьте пасту и перемешайте. Украсьте петрушкой.",
            timeInSeconds: 2 * 60,
          ),
        ],
      ),
      Recipe(
        6,
        "Поке боул с сыром тофу",
        "Свежий гавайский салат с тунцом, авокадо и сырным акцентом.",
        [
          Ingredient(name: "Тунец", measurement: "200 г"),
          Ingredient(name: "Авокадо", measurement: "1 шт."),
          Ingredient(name: "Рис", measurement: "150 г"),
          Ingredient(name: "Соевый соус", measurement: "2 ст. ложки"),
          Ingredient(name: "Сыр фета", measurement: "50 г"),
          Ingredient(name: "Огурец", measurement: "1/2 шт."),
          Ingredient(name: "СеSAMe масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Соль", measurement: "по вкусу"),
        ],
        30 * 60,
        "assets/Images/poke_bowl_with_cheese.png",
        [
          Step(
            stepNumber: 1,
            description: "Отварите рис до готовности и остудите.",
            timeInSeconds: 15 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Нарежьте тунец, авокадо и огурец крупными кубиками.",
            timeInSeconds: 5 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Смешайте соевый соус с кунжутным маслом.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Выложите рис в миску, сверху добавьте ингредиенты.",
            timeInSeconds: 3 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Полейте соусом и посыпьте сыром фета.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
      Recipe(
        7,
        "Тосты с голубикой и бананом",
        "Сладкий и полезный тост с фруктами и мёдом.",
        [
          Ingredient(name: "Хлеб для тостов", measurement: "2 ломтика"),
          Ingredient(name: "Банан", measurement: "1 шт."),
          Ingredient(name: "Черника", measurement: "50 г"),
          Ingredient(name: "Мёд", measurement: "1 ст. ложка"),
          Ingredient(name: "Сливочное масло", measurement: "1 ч. ложка"),
          Ingredient(name: "Кокосовая стружка", measurement: "1 ч. ложка (по желанию)"),
        ],
        45 * 60,
        "assets/Images/toast_with_blueberries_and_banana.png",
        [
          Step(
            stepNumber: 1,
            description: "Поджарьте хлеб в тостере до хруста.",
            timeInSeconds: 3 * 60,
          ),
          Step(
            stepNumber: 2,
            description: "Намажьте тосты сливочным маслом.",
            timeInSeconds: 1 * 60,
          ),
          Step(
            stepNumber: 3,
            description: "Нарежьте банан кружочками и выложите на тосты.",
            timeInSeconds: 2 * 60,
          ),
          Step(
            stepNumber: 4,
            description: "Посыпьте черникой и полейте мёдом.",
            timeInSeconds: 1 * 60,
          ),
          Step(
            stepNumber: 5,
            description: "Посыпьте кокосовой стружкой по желанию.",
            timeInSeconds: 1 * 60,
          ),
        ],
      ),
    ];
  }
}