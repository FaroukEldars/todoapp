import 'package:flutter/material.dart';

/// Person 3: Add Task Screen UI
class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Add Task Screen (Person 3)'),
      ),
    );
  }
}
