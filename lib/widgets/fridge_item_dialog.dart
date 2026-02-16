import 'package:flutter/material.dart';

import '../domain/ingredient_unit.dart';
import '../models/fridge/fridge_item.dart';

class FridgeDialogResult {
  final String name;
  final double amount;
  final IngredientUnit unit;
  final String? existingItemId;

  const FridgeDialogResult({
    required this.name,
    required this.amount,
    required this.unit,
    this.existingItemId,
  });
}

class FridgeItemDialog extends StatefulWidget {
  final List<FridgeItem> existingItems;
  final FridgeItem? editingItem;

  const FridgeItemDialog({
    super.key,
    required this.existingItems,
    this.editingItem,
  });

  @override
  State<FridgeItemDialog> createState() => _FridgeItemDialogState();
}

class _FridgeItemDialogState extends State<FridgeItemDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  IngredientUnit _selectedUnit = IngredientUnit.g;
  FridgeItem? _selectedExisting;
  bool _createAsNew = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();

    if (widget.editingItem != null) {
      _nameController.text = widget.editingItem!.name;
      _amountController.text = (widget.editingItem!.amountBase / widget.editingItem!.unit.toBaseFactor)
          .toStringAsFixed(3)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      _selectedUnit = widget.editingItem!.unit;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingItem != null;
    final query = _nameController.text.trim();

    final suggestions = !isEditing && query.isNotEmpty && !_createAsNew
        ? widget.existingItems
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList()
        : <FridgeItem>[];

    return AlertDialog(
      title: Text(isEditing ? 'Редактировать ингредиент' : 'Добавить ингредиент'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              readOnly: _selectedExisting != null && !_createAsNew,
              decoration: const InputDecoration(
                labelText: 'Название',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (!isEditing) {
                  setState(() {
                    _selectedExisting = null;
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            if (suggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD0D0D0)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    final item = suggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(item.name),
                      subtitle: Text(_displayAmount(item)),
                      onTap: () {
                        setState(() {
                          _selectedExisting = item;
                          _nameController.text = item.name;
                          _selectedUnit = item.unit;
                          _createAsNew = false;
                        });
                      },
                    );
                  },
                ),
              ),
            if (_selectedExisting != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _createAsNew = true;
                      _selectedExisting = null;
                    });
                  },
                  child: const Text('Добавить как новый'),
                ),
              ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Количество',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<IngredientUnit>(
              initialValue: _selectedUnit,
              decoration: const InputDecoration(
                labelText: 'Единица',
                border: OutlineInputBorder(),
              ),
              items: IngredientUnit.values
                  .map(
                    (u) => DropdownMenuItem(
                      value: u,
                      child: Text(u.symbol),
                    ),
                  )
                  .toList(),
              onChanged: (_selectedExisting != null && !_createAsNew)
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUnit = value;
                        });
                      }
                    },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Сохранить' : 'Добавить'),
        ),
      ],
    );
  }

  String _displayAmount(FridgeItem item) {
    final amount = item.amountBase / item.unit.toBaseFactor;
    final text = amount
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return '$text ${item.unit.symbol}';
  }

  void _submit() {
    final name = _nameController.text.trim();
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);

    if (name.isEmpty || amount == null || amount <= 0) {
      return;
    }

    if (_selectedUnit == IngredientUnit.pcs && amount % 1 != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Для шт укажите целое число')),
      );
      return;
    }

    Navigator.pop(
      context,
      FridgeDialogResult(
        name: name,
        amount: amount,
        unit: _selectedUnit,
        existingItemId: (_selectedExisting != null && !_createAsNew)
            ? _selectedExisting!.id
            : null,
      ),
    );
  }
}
