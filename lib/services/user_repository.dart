import 'package:hive/hive.dart';
import '../models/user.dart';

class UserRepository {
  static final String _boxName = 'userBox';
  static final String _userKey = 'currentUser';

  User getUser() {
    final box = Hive.box<User>(_boxName);
    final user = box.get(_userKey);

    if (user != null) {
      return user;
    }

    final newUser = User(
      id: 'local_user',
      name: 'Пользователь',
      avatarPath: null,
    );

    box.put(_userKey, newUser);
    return newUser;
  }

  Future<void> updateAvatar(String avatarPath) async {
    final user = getUser();
    user.avatarPath = avatarPath;
    await user.save();
  }

  Future<void> updateName(String name) async {
    final user = getUser();
    user.name = name;
    await user.save();
  }

  Future<void> removeAvatar() async {
    final user = getUser();
    user.avatarPath = null;
    await user.save();
  }
}