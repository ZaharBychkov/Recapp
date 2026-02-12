import 'package:hive/hive.dart';
import '../models/user.dart';

class UserRepository {
  static final String _boxName = 'userBox';
  static final String _userKey = 'currentUser';

  static Box<User>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<User>(_boxName);
  }

  static Box<User> get _safeBox {
    if (_box == null) {
      throw Exception('UserRepository not initialized');
    }
    return _box!;
  }

  static User? getCurrentUser() {
    return _safeBox.get(_userKey);
  }

  static Future<void> saveUser(User user) async {
    await _safeBox.put(_userKey, user);
  }

  static Future<void> logout() async {
    await _safeBox.delete(_userKey);
  }

  static Future<void> updateName(String name) async {
    final user = getCurrentUser();
    if (user == null) return;

    user.name = name;
    await user.save();
  }

  static Future<void> updateAvatar(String avatarPath) async {
    final user = getCurrentUser();
    if (user == null) return;

    user.avatarPath = avatarPath;
    await user.save();
  }

  static Future<void> removeAvatar() async {
    final user = getCurrentUser();
    if (user == null) return;

    user.avatarPath = null;
    await user.save();
  }
}