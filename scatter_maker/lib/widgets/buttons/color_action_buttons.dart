import 'dart:ui';

import 'package:flutter/material.dart';

final resetIcon = Transform.flip(flipX: true, child: const Icon(Icons.refresh));

class ColorPickerActionButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onPressed;
  final Widget sampleDisplay;
  final VoidCallback resetFunction;

  const ColorPickerActionButton(
      {super.key,
      required this.text,
      required this.selected,
      required this.onPressed,
      required this.sampleDisplay,
      required this.resetFunction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: onPressed,
            style: ButtonStyle(
              side: WidgetStateProperty.all<BorderSide>(BorderSide(
                  color: selected ? Colors.black : Colors.black45, width: 2)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  selected ? Colors.blue.withOpacity(.1) : Colors.white),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            )),
        const SizedBox(
          width: 10,
        ),
        sampleDisplay,
        IconButton(
          icon: resetIcon,
          onPressed: resetFunction,
        ),
      ],
    );
  }
}

class PointBorderSample extends StatelessWidget {
  const PointBorderSample({
    super.key,
    required this.scatterBorderColor,
  });

  final Color scatterBorderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: scatterBorderColor,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FilledPointSample extends StatelessWidget {
  const FilledPointSample({
    super.key,
    required this.scatterBorderColor,
    required this.scatterFillColor,
  });

  final Color scatterBorderColor;
  final Color scatterFillColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: scatterBorderColor,
            shape: BoxShape.circle,
          ),
        ),
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: scatterFillColor,
              shape: BoxShape.circle,
            ),
            transform: Matrix4.translationValues(5, 5, 0))
      ],
    );
  }
}

class RegressionColorSample extends StatelessWidget {
  const RegressionColorSample({
    super.key,
    required this.regressionLineColor,
  });

  final Color regressionLineColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: regressionLineColor,
      ),
    );
  }
}
