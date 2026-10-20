import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/onboarding/splash_screen.dart';

import 'data/services/hive_service.dart';
import 'providers/task_provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  runApp(MyApp(hiveService: hiveService));
}

class MyApp extends StatelessWidget {
  final HiveService hiveService;

  const MyApp({super.key, required this.hiveService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider(hiveService)),
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tasky',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF15B86C),
                primary: const Color(0xFF15B86C),
                brightness: Brightness.light,
                surface: Colors.white,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFF8F9FA),
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              scaffoldBackgroundColor: const Color(0xFF181818),
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF15B86C),
                primary: const Color(0xFF15B86C),
                brightness: Brightness.dark,
                surface: Color(0xFF242424),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF181818),
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              useMaterial3: true,
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
