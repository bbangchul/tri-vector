import 'package:flutter/material.dart';
import 'package:todoey/widgets/geometry_app_shell.dart';

void main() {
  runApp(const GeometryApp());
}

class GeometryApp extends StatelessWidget {
  const GeometryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFFF8A3D),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Geometry Visualizer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF070B14),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: const Color(0xFFF5F7FA),
              displayColor: const Color(0xFFF5F7FA),
            ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF121927),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const GeometryAppShell(),
    );
  }
}

class MyApp extends GeometryApp {
  const MyApp({super.key});
}
