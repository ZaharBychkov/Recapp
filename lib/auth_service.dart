import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyLogin = 'login';
  static const String _keyPassword = 'password';

  Future<bool> register(String login, String password) async {
    final prefs = await SharedPreferences.getInstance();


  }
}