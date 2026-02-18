import 'package:flutter/material.dart';

import 'domain/unit_converter.dart';
import 'models/history/recipe_history_entry.dart';
import 'repositories/fridge_repository.dart';
import 'repositories/history_repository.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final UnitConverter _converter = const UnitConverter();
  List<RecipeHistoryEntry> _entries = <RecipeHistoryEntry>[];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _entries = HistoryRepository.getEntries();
    });
  }

  String _formatDate(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}.${two(dt.month)}.${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  Future<void> _restoreEntry(RecipeHistoryEntry entry) async {
    if (entry.isRestored) return;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Восстановить ингредиенты?',
          style: TextStyle(
            color: Color(0xFF165932),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Вернуть ингредиенты для рецепта "${entry.recipeTitle}" обратно в холодильник?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF165932),
            ),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF165932),
              foregroundColor: Colors.white,
            ),
            child: const Text('Восстановить'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FridgeRepository.restoreOrMerge(entry.consumedItems);
    await HistoryRepository.markRestored(entry.id);

    if (!mounted) return;
    _reload();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ингредиенты восстановлены в холодильник')),
    );
  }

  Widget _buildConsumedList(RecipeHistoryEntry entry) {
    if (entry.consumedItems.isEmpty) {
      return const Text(
        'Списаний не было',
        style: TextStyle(color: Color(0xFF777777), fontFamily: 'Roboto'),
      );
    }

    return Column(
      children: entry.consumedItems.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              const Text(
                '• ',
                style: TextStyle(
                  color: Color(0xFF165932),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                _converter.format(baseAmount: item.amountBase, unit: item.unit),
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        title: const Text(
          'История приготовления',
          style: TextStyle(
            color: Color(0xFF165932),
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _entries.isEmpty
          ? const Center(
              child: Text(
                'История пока пуста',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD9D9D9)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              entry.recipeImagePath,
                              width: 74,
                              height: 74,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.recipeTitle,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(entry.createdAtMillis),
                                  style: const TextStyle(
                                    color: Color(0xFF2ECC71),
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Использовано:',
                        style: TextStyle(
                          color: Color(0xFF165932),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildConsumedList(entry),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: entry.isRestored
                              ? null
                              : () => _restoreEntry(entry),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: entry.isRestored
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF165932),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            entry.isRestored
                                ? 'Уже восстановлено'
                                : 'Восстановить ингредиенты',
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
