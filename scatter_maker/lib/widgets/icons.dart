import 'package:flutter/material.dart';

class PolyDegreeIcon extends StatelessWidget {
  final int degree;
  const PolyDegreeIcon({super.key, required this.degree});

  @override
  Widget build(BuildContext context) {
    return ImageIcon(AssetImage('assets/icons/deg_$degree.png'));
  }
}