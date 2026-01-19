import 'package:flutter/material.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Холодильник',
          style: TextStyle(
            color: Color(0xFF165932),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.04,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'В холодильнике',
                style: TextStyle(
                  color: Color(0xFF165932),
                  fontSize: MediaQuery.of(context).size.width * 0.045,
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
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    _buildItem('Соевый соус', '1 бутылка'),
                    _buildItem('Мёд', '1 бутылка'),
                    _buildItem('Чеснок', '2 шт'),
                    _buildItem('Тёртый имбирь', '1 шт'),
                    _buildItem('Лимонный сок', 'бутылка'),
                    _buildItem('Кукурузный крахмал', 'пакет'),
                    _buildItem('Филе лосося', '700 г'),
                    _buildItem('Соус томатный', '1 бутылка'),
                    _buildItem('Сыр Моцарелла', '400 г'),
                    _buildItem('Помидор', '5 шт'),
                    _buildItem('Базилик зеленый', '1 пачка'),
                  ],
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ECC71),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Рекомендовать рецепты',
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                icon: Image.asset(''), // Вставь путь к изображению
                onPressed: () => _onItemTapped(0),
                color: _selectedIndex == 0 ? Color(0xFF2ECC71) : Colors.grey,
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Image.asset(''), // Вставь путь к изображению
                onPressed: () => _onItemTapped(1),
                color: _selectedIndex == 1 ? Color(0xFF2ECC71) : Colors.grey,
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Image.asset(''), // Вставь путь к изображению
                onPressed: () => _onItemTapped(2),
                color: _selectedIndex == 2 ? Color(0xFF2ECC71) : Colors.grey,
              ),
            ),
            Expanded(
              child: IconButton(
                icon: Image.asset(''), // Вставь путь к изображению
                onPressed: () => _onItemTapped(3),
                color: _selectedIndex == 3 ? Color(0xFF2ECC71) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String name, String quantity) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.014,
            height: MediaQuery.of(context).size.width * 0.02,
            margin: EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              color: Colors.black,
              fontSize: MediaQuery.of(context).size.width * 0.035,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          Text(
            quantity,
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
  }
}