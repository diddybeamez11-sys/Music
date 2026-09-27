import 'package:flutter/material.dart';
import 'screens/shell_screen.dart';

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Aurora', debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xff101014), colorScheme: const ColorScheme.dark(primary: Color(0xffc9a7ff), surface: Color(0xff1b1a20)), textTheme: const TextTheme(displaySmall: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -.8), titleLarge: TextStyle(fontWeight: FontWeight.w700), titleMedium: TextStyle(fontWeight: FontWeight.w600)), useMaterial3: true),
    home: const ShellScreen(),
  );
}
