import 'package:flutter/material.dart';

class DottedContainer extends StatelessWidget {
  final double height;
  final Widget child;

  const DottedContainer({super.key, required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white24,
          style: BorderStyle.solid,
          width: 1,
        ),
      ),
      child: child,
    );
  }
}
