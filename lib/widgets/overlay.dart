import 'package:flutter/material.dart';

class LoadingStatusBar extends StatelessWidget {
  final String message;

  const LoadingStatusBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: 400,
        child: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
