import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Function() onPressed;
  final String children;

  const PrimaryButton({
    super.key,
    required this.onPressed,
    required this.children
});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white
      ),
        onPressed: onPressed,
        child: Text(children, style: const TextStyle(fontWeight: FontWeight.bold),
        )
    );
  }
}