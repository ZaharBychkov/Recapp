import 'repositories/fridge_repository.dart';
import 'repositories/history_repository.dart';
import 'services/recipe_repository.dart';
import 'services/user_repository.dart';

class AppBootstrap {
  static Future<void>? _future;

  static Future<void> start() {
    _future ??= Future.wait<void>([
      UserRepository.init(),
      RecipeRepository.init(),
      FridgeRepository.init(),
      HistoryRepository.init(),
    ]);
    return _future!;
  }
}
