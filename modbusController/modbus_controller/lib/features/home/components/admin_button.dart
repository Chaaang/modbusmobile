import 'package:flutter/material.dart';

class AdminButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Color color;
  const AdminButton({
    super.key,
    required this.text,
    this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 400,
        height: 100,
        decoration: BoxDecoration(color: color, shape: BoxShape.rectangle),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
