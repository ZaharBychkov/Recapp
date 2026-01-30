import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    if(widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _amountController.text = widget.ingredient!.measurement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.0001),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.35,
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ингредиент',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.05,
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              _buildInput(
                controller: _nameController,
                label: 'Название ингредиента',
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.02),

              _buildInput(
                controller: _amountController,
                label: 'Количество',
              ),

              const Spacer(),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_nameController.text.isEmpty ||
                          _amountController.text.isEmpty) {
                        return;
                      }

                      Navigator.pop(
                        context,
                        Ingredient(
                          name: _nameController.text,
                          measurement: _amountController.text,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71),
                      padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.02),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                      ),
                    ),
                    child: Text(
                      widget.ingredient == null ? 'Добавить' : 'Изменить',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height * 0.01,
        left: MediaQuery.of(context).size.width * 0.07,
        right: MediaQuery.of(context).size.width * 0.07,
        bottom: MediaQuery.of(context).size.height * 0.01,
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

          SizedBox(height: MediaQuery.of(context).size.height * 0.01),

          TextField(
            controller: controller,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
          ),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            )
          ),
        ],
      ),
    );
  }
}