import 'package:flutter/material.dart';
import 'dart:html' as html;

const donateLink =
    "https://www.paypal.com/donate/?business=C8ES9DJA6YMBQ&no_recurring=0&currency_code=USD";
final donateURI = Uri.parse(donateLink);

class IconActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const IconActionButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
          side: WidgetStateProperty.all(
              const BorderSide(color: Colors.black54, width: 2))),
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 5),
          Text(text, style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

class PaypalDonateButton extends StatelessWidget {
  const PaypalDonateButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const IconActionButton(
      text: 'Donate',
      icon: Icons.paypal,
      onPressed: openPaypalLink,
    );
  }
}

void openPaypalLink() {
  html.window.open(donateURI.toString(), 'new tab');
}
