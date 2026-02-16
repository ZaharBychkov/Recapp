import 'package:flutter/material.dart';

import 'models/fridge/fridge_item.dart';
import 'models/recipe.dart';
import 'repositories/fridge_repository.dart';
import 'recipe_manager.dart';
import 'widgets/fridge_item_dialog.dart';
import 'domain/name_sanitizer.dart';
import 'domain/unit_converter.dart';
import 'services/recipe_availability_service.dart';
import '../utils/time_formatter.dart';

class FridgeScreen extends StatefulWidget {
  const FridgeScreen({super.key});

  @override
  State<FridgeScreen> createState() => _FridgeScreenState();
}

class _FridgeScreenState extends State<FridgeScreen> {
  final UnitConverter _converter = const UnitConverter();
  final RecipeAvailabilityService _availabilityService = const RecipeAvailabilityService();

  List<FridgeItem> _items = <FridgeItem>[];
  List<Recipe> recommendedRecipes = <Recipe>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final loaded = FridgeRepository.getItems();
    if (!mounted) return;

    setState(() {
      _items = loaded;
      _loading = false;
    });
  }

  Future<void> _addIngredient() async {
    final result = await showDialog<FridgeDialogResult>(
      context: context,
      builder: (_) => FridgeItemDialog(existingItems: _items),
    );

    if (result == null) return;

    final name = NameSanitizer.normalize(result.name);
    final amountBase = _converter.toBase(amount: result.amount, unit: result.unit);

    final normalizedName = name.toLowerCase();
    final autoMergeIndex = _items.indexWhere(
      (item) =>
          item.name.toLowerCase() == normalizedName &&
          item.unit.category == result.unit.category,
    );
    final shouldMerge = !result.forceCreateNew &&
        (result.existingItemId != null || autoMergeIndex != -1);

    if (shouldMerge) {
      await FridgeRepository.addToExisting(
        itemId: result.existingItemId ?? _items[autoMergeIndex].id,
        deltaBase: amountBase,
      );
    } else {
      await FridgeRepository.addNew(
        name: name,
        amountBase: amountBase,
        unit: result.unit,
      );
    }

    await _reload();
  }

  Future<void> _editIngredient(FridgeItem item) async {
    final result = await showDialog<FridgeDialogResult>(
      context: context,
      builder: (_) => FridgeItemDialog(
        existingItems: _items,
        editingItem: item,
      ),
    );

    if (result == null) return;

    final name = NameSanitizer.normalize(result.name);
    final hasExactDuplicate = _items.any((e) => e.id != item.id && e.name == name);
    if (hasExactDuplicate) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Такой ингредиент уже существует. Отредактируйте существующий.'),
          ),
        );
      }
      return;
    }

    final amountBase = _converter.toBase(amount: result.amount, unit: result.unit);

    await FridgeRepository.updateItem(
      item.copyWith(
        name: name,
        unit: result.unit,
        amountBase: amountBase,
      ),
    );

    await _reload();
  }

  Future<void> _deleteIngredient(FridgeItem item) async {
    await FridgeRepository.deleteItem(item.id);
    await _reload();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final list = List<FridgeItem>.from(_items);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    await FridgeRepository.reorderItems(list.map((e) => e.id).toList());
    await _reload();
  }

  void _compareWithRecipes() {
    final allRecipes = RecipeManager().getRecipes();
    final matching = <Recipe>[];

    for (final recipe in allRecipes) {
      final result = _availabilityService.checkAndBuildConsumption(
        recipeIngredients: recipe.ingredients,
        fridgeItems: _items,
      );

      if (result.hasAllIngredients) {
        matching.add(recipe);
      }
    }

    setState(() {
      recommendedRecipes = matching;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.04,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'В холодильнике',
                        style: TextStyle(
                          color: const Color(0xFF165932),
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_items.isEmpty)
                        const Text('Список пуст')
                      else
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _items.length,
                          onReorder: _onReorder,
                          buildDefaultDragHandles: false,
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            return Container(
                              key: ValueKey(item.id),
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: item.isDepleted ? const Color(0xFFFFE6E6) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(Icons.drag_indicator, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.035,
                                        fontWeight: FontWeight.w600,
                                        decoration: item.isDepleted
                                            ? TextDecoration.lineThrough
                                            : TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _converter.format(baseAmount: item.amountBase, unit: item.unit),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: MediaQuery.of(context).size.width * 0.033,
                                      decoration: item.isDepleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _editIngredient(item),
                                    icon: const Icon(Icons.edit, size: 18),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteIngredient(item),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: _addIngredient,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Добавить ингредиент',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: _compareWithRecipes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Рекомендовать рецепты',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                if (recommendedRecipes.isNotEmpty)
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                if (recommendedRecipes.isNotEmpty)
                  Column(
                    children: recommendedRecipes.map((recipe) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: MediaQuery.of(context).size.width * 0.925,
                        height: MediaQuery.of(context).size.height * 0.147,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 20,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  bottomLeft: Radius.circular(10),
                                ),
                                child: Image.asset(
                                  recipe.imagePath,
                                  fit: BoxFit.cover,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                            Expanded(
                              flex: 33,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recipe.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width * 0.06,
                                        fontWeight: FontWeight.w600,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Image.asset('assets/Icons/clock.png', width: MediaQuery.of(context).size.width * 0.05),
                                        const SizedBox(width: 8),
                                        Text(
                                          formatTime(recipe.prepTimeSeconds),
                                          style: TextStyle(
                                            color: const Color(0xFF2ECC71),
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
