import 'package:flutter/material.dart';

class EndScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.blue, Colors.red],
            center: Alignment(0.0, 0.0), // near the top right
            radius: 0.98,
          ),
        ),
        child: Center(
          child: Text(
            'End Screen',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}