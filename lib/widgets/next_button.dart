import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final String label;
  final void Function()? onPressed;
  final Color color;
  final TextStyle textStyle;

  const NextButton({
    Key? key,
    required this.onPressed,
    this.label = "Далее",
    this.color = Colors.blue,
    this.textStyle = const TextStyle(color: Colors.white),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: MaterialStateProperty.all<Size>(const Size.fromHeight(40)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Theme.of(context).disabledColor;
            }
            return Theme.of(context).primaryColor;
          },
        ),
        foregroundColor:
            MaterialStateProperty.all<Color>(Colors.white), // Text color
      ),
      child: Text(label),
    );
  }
}
