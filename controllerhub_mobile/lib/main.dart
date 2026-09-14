import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ControllerHubApp(),
  );
}

class ControllerHubApp
    extends StatelessWidget {
  const ControllerHubApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ControllerHub',
      theme: ThemeData(
        brightness:
            Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(
          0xFF0D0F14,
        ),
        colorScheme:
            ColorScheme.fromSeed(
          seedColor:
              Colors.blue,
          brightness:
              Brightness.dark,
        ),
      ),
      home:
          const HomeScreen(),
    );
  }
}