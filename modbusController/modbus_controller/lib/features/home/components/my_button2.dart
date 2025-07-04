import 'package:flutter/material.dart';

class MyButton2 extends StatelessWidget {
  final String imageAssetPath;
  final String text;
  final VoidCallback? onTap;
  final double size;

  const MyButton2({
    super.key,
    required this.imageAssetPath,
    required this.text,
    this.onTap,
    this.size = 265,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            ClipOval(
              child: Image.asset(
                imageAssetPath,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SizedBox(
                width: size * 0.6, // constraint to allow wrapping
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
