import 'package:flutter/material.dart';

import '../domain/ingredient_unit.dart';
import '../domain/recipe_measurement_parser.dart';
import '../models/ingredient.dart';

class AddIngredientDialog extends StatefulWidget {
  final Ingredient? ingredient;

  const AddIngredientDialog({super.key, this.ingredient});

  @override
  State<AddIngredientDialog> createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final RecipeMeasurementParser _parser = const RecipeMeasurementParser();
  IngredientUnit? _selectedUnit;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
    _amountController.addListener(_refresh);

    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _prefillFromMeasurement(widget.ingredient!.measurement);
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _amountController.removeListener(_refresh);
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _isValid {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim().replaceAll(',', '.'));
    if (name.isEmpty) return false;
    if (_selectedUnit == null) return false;
    if (amount == null || amount <= 0) return false;
    if (_selectedUnit == IngredientUnit.pcs && amount % 1 != 0) return false;
    return true;
  }

  void _prefillFromMeasurement(String measurement) {
    final normalized = measurement.trim().toLowerCase();
    final direct = RegExp(
      r'^(\d+(?:[.,]\d+)?)\s*(мг|г|кг|мл|л|шт\.?)$',
      caseSensitive: false,
    ).firstMatch(normalized);

    if (direct != null) {
      final amountToken = direct.group(1)!.replaceAll(',', '.');
      final unitToken = direct.group(2)!;
      _amountController.text = amountToken;
      _selectedUnit = IngredientUnitX.fromSymbol(unitToken);
      return;
    }

    final parsed = _parser.parse(measurement);
    if (parsed == null) return;

    final amount = parsed.baseAmount / parsed.unit.toBaseFactor;
    _amountController.text = amount
        .toStringAsFixed(3)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    _selectedUnit = parsed.unit;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.85),
        child: SingleChildScrollView(
          child: Container(
            width: size.width * 0.9,
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ингредиент',
                  style: TextStyle(
                    fontSize: size.width * 0.05,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                _buildInput(
                  controller: _nameController,
                  label: 'Название ингредиента',
                ),
                SizedBox(height: size.height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: _buildInput(
                        controller: _amountController,
                        label: 'Количество',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    SizedBox(width: size.width * 0.03),
                    Expanded(
                      child: _buildUnitInput(),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.02),
                Center(
                  child: SizedBox(
                    width: size.width * 0.6,
                    child: ElevatedButton(
                      onPressed: _isValid
                          ? () {
                              final amountRaw = _amountController.text
                                  .trim()
                                  .replaceAll(',', '.');
                              final measurement =
                                  '$amountRaw ${_selectedUnit!.symbol}';

                              Navigator.pop(
                                context,
                                Ingredient(
                                  name: _nameController.text.trim(),
                                  measurement: measurement,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isValid ? const Color(0xFF2ECC71) : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(size.width * 0.05),
                        ),
                      ),
                      child: Text(
                        widget.ingredient == null ? 'Добавить' : 'Изменить',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.01,
        left: size.width * 0.07,
        right: size.width * 0.07,
        bottom: size.height * 0.01,
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
              color: Color(0xff165932),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
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
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.01,
        left: size.width * 0.04,
        right: size.width * 0.04,
        bottom: size.height * 0.01,
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
      child: DropdownButtonHideUnderline(
        child: DropdownButton<IngredientUnit>(
          value: _selectedUnit,
          isExpanded: true,
          hint: const Text(
            'Ед.',
            style: TextStyle(
              color: Color(0xFF165932),
              fontWeight: FontWeight.w600,
            ),
          ),
          onChanged: (value) {
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
