import 'package:flutter/material.dart';

/// Person 6: User Details Screen UI
class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('User Details Screen (Person 6)'),
      ),
    );
  }
}
