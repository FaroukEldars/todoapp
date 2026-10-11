import 'package:flutter/material.dart';

/// Person 4: Active Tasks UI
class MyTasksScreen extends StatelessWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('My Tasks Screen (Person 4)'),
      ),
    );
  }
}
