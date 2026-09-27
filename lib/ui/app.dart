import 'package:flutter/material.dart';
import 'screens/shell_screen.dart';

class AuroraApp extends StatelessWidget {
  const AuroraApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Aurora', debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xff121212),
      colorScheme: const ColorScheme.dark(primary: Color(0xffff375f), surface: Color(0xff1c1c1e)),
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, letterSpacing: -1.1),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -.3),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: Color(0xee1c1c1e),
        indicatorColor: Colors.transparent,
        labelTextStyle: MaterialStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: Color(0xffff375f),
        inactiveTrackColor: Color(0xff48484a),
        thumbColor: Color(0xffff375f),
      ),
      useMaterial3: true,
    ),
    home: const ShellScreen(),
  );
}

class AuroraLoadingApp extends StatelessWidget {
  const AuroraLoadingApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xff121212),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.music_note_rounded, color: Color(0xffff375f), size: 56),
                SizedBox(height: 16),
                Text('Aurora', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
                SizedBox(height: 20),
                SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xffff375f))),
              ],
            ),
          ),
        ),
      );
}
