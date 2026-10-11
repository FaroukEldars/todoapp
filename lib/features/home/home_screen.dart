import 'package:flutter/material.dart';

/// Person 2: Home Screen UI
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Home Screen (Person 2)'),
      ),
    );
  }
}
