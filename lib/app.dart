import 'package:flutter/material.dart';
import 'screens/home_page.dart';

class MalariaApp extends StatelessWidget {
  const MalariaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Flutter Demo',
    theme: ThemeData(
      highlightColor: const Color(0xFFD0996F),
      canvasColor: const Color(0xFFFDF5EC),
      textTheme: ThemeData.light().textTheme.copyWith(
        headlineSmall: const TextStyle(color: Color(0xFFBC764A)),
      ),
      iconTheme: IconThemeData(color: Colors.grey[600]),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFBC764A),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBC764A)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFBC764A),
          side: const BorderSide(color: Color(0xFFBC764A)),
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
          .copyWith(surface: const Color(0xFFFDF5EC)),
    ),
    home: const HomePage(title: 'Malaria Detection'),
  );
}
