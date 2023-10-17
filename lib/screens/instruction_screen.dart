import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstructionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text('How to Use the App'),
            Text('Add new jaap counting section.'),
            // More instructions as needed...
          ],
        ),
      ),
    );
  }
}
