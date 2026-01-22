import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

//Future<bool> - Future используется тольк при ассинхронной загрузке
//await - ждем пока ассинхронная операция завершится, прежде чем продолжать с ней работу

//SharedPreferences — один на устройство
// Это не общее хранилище для всех приложений.
// Это хранилище только для твоего приложения.
// На одном устройстве может быть только один пользователь в SharedPreferences


class AuthService {
  static const String _keyLogin = 'login';
  static const String _keyPassword = 'password';

  //Регистрация пользователя
  Future<bool> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();          //Доступ к локальном хранилищу
     //Существует ли такой - же пользователь
    if (prefs.getString(_keyLogin) != null) {                      //Есть ли уже такой логин
      return false;                                               //Если есть, возвращаем false - регитрация не удалась
    }

    //Сохраняем нового пользователя
    await prefs.setString(_keyLogin, login);                      //Сохраняем логин во внутренней хранилище
    await prefs.setString(_keyPassword, password);                //Сохраняем пароль во внутренней хранилище
    return true;                                                   //Регистрация успешна
  }

  //Авторизция - соответсвует ли то что пользователь ввел с тем что есть в базе

  Future<bool> login(String login, String password) async {                 //Получаем сохраненный логин
    final prefs = await SharedPreferences.getInstance();                   //Получаем сохраненные пароль

    final savedLogin = prefs.getString(_keyLogin);
    final savedPassword = prefs.getString(_keyPassword);

    if (savedLogin == login && savedPassword == password) {
      return true;
    }
    return false;
  }

  //Авторизован ли пользователь, существует ли логин
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();       //Получаем доступ к внутреннем хранилищу
    return prefs.getString(_keyLogin) != null;                  //Если логин существует возвращаем true
  }

  //Выход из системы
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();       //Получаем доступ к внутреннему хранилищу
    await prefs.remove(_keyLogin);                               //Удаляем логин из хранилища
    await prefs.remove(_keyPassword);                             //Удаляем пароль из хранилища
  }

  //Получить текущего пользователя, чтобы не авторизовываться каждый раз при входе в приложение
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final login = prefs.getString(_keyLogin);
    final password = prefs.getString(_keyPassword);

    if (login != null && password != null) { // Проверяем, существуют ли логин и пароль
      return User(login, password); // Если да — создаём и возвращаем объект User
    }
    return null; // Если нет — возвращаем null
  }
}