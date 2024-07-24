import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void _showOverlay(BuildContext context) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 100,
      left: 50,
      child: Center(
        child: Container(
          color: Colors.blueAccent,
          width: 200,
          height: 100,
          child: const Center(
            child: Text(
              'Hello, Overlay!',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry into the Overlay
  overlay?.insert(overlayEntry);

  // Remove the overlay after 3 seconds
  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}
