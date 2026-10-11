import 'package:flutter/material.dart';

/// Person 6: Profile & Settings UI
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Profile Screen (Person 6)'),
      ),
    );
  }
}
