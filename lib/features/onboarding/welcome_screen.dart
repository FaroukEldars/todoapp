import 'package:flutter/material.dart';

/// Person 3: Welcome Screen UI
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Welcome Screen (Person 3)'),
      ),
    );
  }
}
