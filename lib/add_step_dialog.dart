import 'package:flutter/material.dart';
import '../models/step.dart';

class AddStepDialog extends StatefulWidget {
  final RecipeStep? step;

  const AddStepDialog({super.key, this.step});

  @override
  State<AddStepDialog> createState() => _AddStepDialogState();
}

class _AddStepDialogState extends State<AddStepDialog> {
  final TextEditingController _stepController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _secondsController = TextEditingController();

  @override
  void dispose() {
    _stepController.removeListener(_refresh);
    _stepController.dispose();
    _minutesController.dispose();
    _secondsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _stepController.addListener(_refresh);

    if(widget.step != null) {
      _stepController.text = widget.step!.description;

      final minutes = widget.step!.timeInSeconds ~/60;
      final seconds = widget.step!.timeInSeconds % 60;

      _minutesController.text = minutes.toString();
      _secondsController.text = seconds.toString();
    }
  }

  int _parseTime(String value) {
    final intValue = int.tryParse(value) ?? 0;
    return intValue.clamp(0, 59);
  }

  bool get _canSubmit => _stepController.text.trim().isNotEmpty;

  void _refresh() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: size.height * 0.9,
        ),
        child: SingleChildScrollView(
          child: Container(
        width: size.width * 0.9,
        padding: EdgeInsets.all(size.width * 0.04),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ЗАГОЛОВОК
            Text(
              'Шаг приготовления',
              style: TextStyle(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: size.height * 0.02),

            /// ПОЛЕ ШАГА
            _buildStepInput(context),

            SizedBox(height: size.height * 0.02),

            /// ВРЕМЯ
            Text(
              'Время приготовления',
              style: TextStyle(
                color: const Color(0xFF165932),
                fontSize: size.width * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: size.height * 0.01),

            /// МИНУТЫ + СЕКУНДЫ
            Row(
              children: [
                Expanded(
                  child: _buildTimeInput(
                    context,
                    controller: _minutesController,
                    label: 'Минуты',
                    hint: '59',
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                Expanded(
                  child: _buildTimeInput(
                    context,
                    controller: _secondsController,
                    label: 'Секунды',
                    hint: '59',
                  ),
                ),
            ],
          ),

            SizedBox(height: size.height * 0.025),

            /// КНОПКА
            Center(
              child: SizedBox(
                width: size.width * 0.6,
                child: ElevatedButton(
                  onPressed: _canSubmit ? () {
                    final stepText = _stepController.text.trim();
                    final minutes = _parseTime(_minutesController.text);
                    final seconds = _parseTime(_secondsController.text);

                    Navigator.pop(
                      context,
                      {
                        'step': stepText,
                        'minutes': minutes,
                        'seconds': seconds,
                      },
                    );
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmit
                        ? const Color(0xFF2ECC71)
                        : Colors.grey,
                    padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.02,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.05,
                      ),
                    ),
                  ),
                  child: Text(
                    widget.step == null ? 'Добавить' : 'Изменить',
                    style: TextStyle(color: Colors.white),
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

  Widget _buildStepInput(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.only(
        top: size.height * 0.015,
        left: size.width * 0.07,
        right: size.width * 0.07,
        bottom: size.height * 0.015,
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
          const Text(
            'Описание шага',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xff165932),
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: size.height * 0.01),

          TextField(
            controller: _stepController,
            minLines: 4,
            maxLines: 6,
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


  /// МИНУТЫ / СЕКУНДЫ
  Widget _buildTimeInput(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required String hint,
      }) {

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.01,
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
          SizedBox(height: MediaQuery.of(context).size.height * 0.005),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
