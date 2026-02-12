import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'services/user_repository.dart';

class AuthService {
  Future<bool> register(String login, String password) async {
    final existingUser = UserRepository.getCurrentUser();

    if (existingUser != null) {
      return false;
    }

    final newUser = User(
      id: login,
      name: login,
      login: login,
      password: password,
      avatarPath: null,
    );

    await UserRepository.saveUser(newUser);
    return true;
  }

  Future<bool> login(String login, String password) async {
    final user = UserRepository.getCurrentUser();

    if (user == null) return false;

    return user.login == login && user.password == password;
  }

  Future<bool> isLoggedIn() async {
    return UserRepository.getCurrentUser() != null;
  }

  Future<void> logout() async {
    await UserRepository.logout();
  }

  Future<User?> getCurrentUser() async {
    return UserRepository.getCurrentUser();
  }

}