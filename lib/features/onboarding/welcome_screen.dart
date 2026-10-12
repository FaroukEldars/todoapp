import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../providers/task_provider.dart';
import '../../providers/user_provider.dart';
import '../navigation/main_navigation_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

Future<void> _start() async {
  final name = _nameController.text.trim();

  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your name'),
      ),
    );
    return;
  }

  try {
    final box = await Hive.openBox('home_settings');
    await box.put('userName', name);

    if (!mounted) return;

    final user = context.read<UserProvider>();
    final tasks = context.read<TaskProvider>();

    user.setUser(
      name: name,
      userId: 1,
      email: '',
    );

    await tasks.loadTasks('1');

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const MainNavigationScreen(),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not start the app. Please try again .'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818),
      appBar: AppBar(
        backgroundColor: Color(0xff181818),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 40, height: 40),
              const Text(
                '  Tasky',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome To Tasky 👋',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your productivity journey starts here',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Image.asset('assets/onb.png', width: 300, height: 300),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Full Name',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    controller: _nameController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF282828),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),

                      hintText: 'e.g. John Doe',
                      hintStyle: TextStyle(color: Colors.white38),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF15B86C),
                    minimumSize: const Size(365, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),

                  onPressed: _start,
                  child: Text(
                    'Let\'s Get Started',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
