import 'package:flutter/material.dart';

class TransparentCard extends StatelessWidget {
  final Widget child;

  const TransparentCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.15),
      child: Padding(padding: const EdgeInsets.all(16.0), child: child),
    );
  }
}
