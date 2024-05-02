import 'package:flutter/material.dart';
import 'package:kauno/view/screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'kauno',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.blueGrey[50]
      ),
      darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.black, brightness: Brightness.dark),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50]
      ),
      themeMode: ThemeMode.system,
      home: const Screen(),
    );
  }
}

