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
  String? _initialNameNormalized;
  IngredientUnit? _initialUnit;
  int? _initialAmountBase;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();

    if (widget.editingItem != null) {
      _nameController.text = widget.editingItem!.name;
      _amountController.text = _formatAmount(
        widget.editingItem!.amountBase,
        widget.editingItem!.unit,
      );
      _selectedUnit = widget.editingItem!.unit;
      _initialNameNormalized = _normalizeName(widget.editingItem!.name);
      _initialUnit = widget.editingItem!.unit;
      _initialAmountBase = widget.editingItem!.amountBase;
    }

    _nameController.addListener(_rebuildForValidation);
    _amountController.addListener(_rebuildForValidation);
  }

  @override
  void dispose() {
    _nameController.removeListener(_rebuildForValidation);
    _amountController.removeListener(_rebuildForValidation);
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final insets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.editingItem != null;
    final suggestions = _buildSuggestions(isEditing: isEditing);
    final validation = _validationState(isEditing: isEditing);
    final canSave = validation == _FridgeValidation.ok;
    final message = _validationMessage(validation);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleCloseAttempt();
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: insets.bottom),
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: size.width,
              height: size.height * 0.8,
              padding: EdgeInsets.fromLTRB(
                size.width * 0.04,
                size.height * 0.01,
                size.width * 0.04,
                size.height * 0.02,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.012),
              Text(
                isEditing ? 'Редактировать ингредиент' : 'Ингредиент',
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: size.height * 0.012),
              _buildInput(
                controller: _nameController,
                label: 'Название',
                onChanged: (_) {
                  if (!isEditing) {
                    setState(() {
                      final wasUsingExisting = _isUsingExisting;
                      _selectedExisting = null;
                      if (wasUsingExisting) {
                        _amountController.clear();
                      }
                    });
                  }
                },
              ),
              SizedBox(height: size.height * 0.012),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildInput(
                      controller: _amountController,
                      label: 'Количество',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  SizedBox(width: size.width * 0.008),
                  Expanded(
                    flex: 5,
                    child: _buildUnitInput(),
                  ),
                ],
              ),
              if (_isUsingExisting)
                Padding(
                  padding: EdgeInsets.only(top: size.height * 0.007),
                  child: const Text(
                    'Введите итоговое количество',
                    style: TextStyle(
                      color: Color(0xFF165932),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(height: size.height * 0.01),
              const Text(
                'Найденные ингредиенты в холодильнике (нажмите, чтобы выбрать)',
                style: TextStyle(
                  color: Color(0xFF165932),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: size.height * 0.006),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffeeeeee),
                    border: Border.all(color: const Color(0xFF165932), width: 1),
                  ),
                  child: suggestions.isEmpty
                      ? const Center(child: Text('Ничего не найдено'))
                      : ListView.separated(
                          itemCount: suggestions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = suggestions[index];
                            final isSelected = _selectedExisting?.id == item.id;
                            return ListTile(
                              dense: true,
                              selected: isSelected,
                              title: Text(
                                item.name,
                                style: TextStyle(
                                  decoration: item.isDepleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: item.isDepleted ? Colors.red[700] : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                _displayAmount(item),
                                style: TextStyle(
                                  decoration: item.isDepleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: item.isDepleted ? Colors.red[700] : Colors.grey[700],
                                ),
                              ),
                              onTap: isEditing
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedExisting = item;
                                        _nameController.text = item.name;
                                        _selectedUnit = item.unit;
                                        _amountController.text = _formatAmount(
                                          item.amountBase,
                                          item.unit,
                                        );
                                      });
                                    },
                            );
                          },
                        ),
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handleCloseAttempt,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF165932), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(color: Color(0xFF165932)),
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.01),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: canSave ? _submit : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canSave ? const Color(0xFF2ECC71) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Сохранить',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.008),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.01,
                  vertical: size.height * 0.006,
                ),
                decoration: BoxDecoration(
                  color: validation == _FridgeValidation.ok
                      ? const Color(0xFFEAF8EF)
                      : const Color(0xFFFFF2F2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: validation == _FridgeValidation.ok
                        ? const Color(0xFF2ECC71)
                        : Colors.red.shade300,
                  ),
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: validation == _FridgeValidation.ok
                        ? const Color(0xFF165932)
                        : Colors.red.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isUsingExisting => _selectedExisting != null;

  List<FridgeItem> _buildSuggestions({required bool isEditing}) {
    if (isEditing) return <FridgeItem>[];

    final query = _normalizeName(_nameController.text);
    final filtered = widget.existingItems.where((item) {
      if (query.isEmpty) return true;
      return _normalizeName(item.name).contains(query);
    }).toList();

    filtered.sort((a, b) {
      if (a.isDepleted != b.isDepleted) {
        return a.isDepleted ? 1 : -1;
      }

      if (query.isEmpty) {
        return a.displayOrder.compareTo(b.displayOrder);
      }

      final aStarts = _normalizeName(a.name).startsWith(query);
      final bStarts = _normalizeName(b.name).startsWith(query);

      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.displayOrder.compareTo(b.displayOrder);
    });

    return filtered;
  }

  List<FridgeItem> _exactNameMatches() {
    final query = _normalizeName(_nameController.text);
    if (query.isEmpty) return <FridgeItem>[];

    return widget.existingItems
        .where((item) => _normalizeName(item.name) == query)
        .toList();
  }

  String _normalizeName(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }

  String _formatAmount(int amountBase, IngredientUnit unit) {
    return (amountBase / unit.toBaseFactor)
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  Future<void> _handleCloseAttempt() async {
    final validation = _validationState(isEditing: widget.editingItem != null);
    final isEditing = widget.editingItem != null;
    final shouldAskConfirm = validation == _FridgeValidation.ok && (!isEditing || _hasUnsavedChanges());

    if (!shouldAskConfirm) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final action = await showDialog<_CloseAction>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text(
            'Закрыть без сохранения?',
            style: TextStyle(
              color: Color(0xFF165932),
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text('Сохранить изменения перед закрытием?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_CloseAction.cancel),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF165932),
              ),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_CloseAction.discard),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF165932),
              ),
              child: const Text('Без сохранения'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(_CloseAction.save),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (action == _CloseAction.discard) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    if (action == _CloseAction.save) {
      _submit();
    }
  }

  void _rebuildForValidation() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _hasUnsavedChanges() {
    if (widget.editingItem == null) return false;

    final currentName = _normalizeName(_nameController.text);
    final currentUnit = _selectedUnit;
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final parsed = double.tryParse(rawAmount);
    final currentBase = parsed == null
        ? null
        : (parsed * currentUnit.toBaseFactor).round();

    return currentName != _initialNameNormalized ||
        currentUnit != _initialUnit ||
        currentBase != _initialAmountBase;
  }

  String _displayAmount(FridgeItem item) {
    final text = _formatAmount(item.amountBase, item.unit);
    final suffix = item.isDepleted ? ' (исчерпан)' : '';
    return '$text ${item.unit.symbol}$suffix';
  }

  void _submit() {
    final validation = _validationState(isEditing: widget.editingItem != null);
    if (validation != _FridgeValidation.ok) {
      return;
    }

    final name = _nameController.text.trim();
    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.parse(rawAmount);

    Navigator.pop(
      context,
      FridgeDialogResult(
        name: name,
        amount: amount,
        unit: _selectedUnit,
        existingItemId: _isUsingExisting ? _selectedExisting!.id : null,
      ),
    );
  }

  _FridgeValidation _validationState({required bool isEditing}) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return _FridgeValidation.emptyName;

    final rawAmount = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(rawAmount);
    if (amount == null || amount <= 0) return _FridgeValidation.invalidAmount;

    if (_selectedUnit == IngredientUnit.pcs && amount % 1 != 0) {
      return _FridgeValidation.invalidPiecesAmount;
    }

    if (!isEditing && !_isUsingExisting) {
      final hasDuplicate = widget.existingItems.any(
        (item) => _normalizeName(item.name) == _normalizeName(name),
      );
      if (hasDuplicate) return _FridgeValidation.duplicateName;
    }

    return _FridgeValidation.ok;
  }

  String _validationMessage(_FridgeValidation state) {
    switch (state) {
      case _FridgeValidation.ok:
        return 'Можно сохранить изменения';
      case _FridgeValidation.emptyName:
        return 'Введите название ингредиента';
      case _FridgeValidation.invalidAmount:
        return 'Введите корректное количество (> 0)';
      case _FridgeValidation.invalidPiecesAmount:
        return 'Для "шт" укажите целое число';
      case _FridgeValidation.duplicateName:
        return 'Такой ингредиент уже существует. Выберите его в списке';
    }
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.006,
        left: size.width * 0.015,
        right: size.width * 0.015,
        bottom: size.height * 0.006,
      ),
      decoration: const BoxDecoration(
        color: Color(0xffeeeeee),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF165932),
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF165932),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.004),
          TextField(
            controller: controller,
            readOnly: _isUsingExisting && controller == _nameController,
            keyboardType: keyboardType,
            onTap: () {
              if (controller == _nameController && _isUsingExisting) {
                setState(() {
                  _selectedExisting = null;
                  _amountController.clear();
                });
              }
            },
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: Color(0xffeeeeee),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF165932),
            width: 3,
          ),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IngredientUnit>(
          value: _selectedUnit,
          isExpanded: true,
          onChanged: _isUsingExisting
              ? null
              : (value) {
                  if (value == null) return;
                  setState(() {
                    _selectedUnit = value;
                  });
                },
          items: IngredientUnit.values
              .map(
                (u) => DropdownMenuItem(
                  value: u,
                  child: Text(
                    u.symbol,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

enum _CloseAction { save, discard, cancel }

enum _FridgeValidation {
  ok,
  emptyName,
  invalidAmount,
  invalidPiecesAmount,
  duplicateName,
}
