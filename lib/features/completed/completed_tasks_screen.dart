import 'package:flutter/material.dart';

/// Person 5: Completed Tasks UI
class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Completed Tasks Screen (Person 5)'),
      ),
    );
  }
}
