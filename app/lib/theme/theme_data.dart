// theme data
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: isDarkTheme ? const Color.fromRGBO(48, 32, 77, 1.0) : Colors.white,
      // primaryColor: const Color.fromRGBO(48, 32, 77, 1.0),
      appBarTheme: AppBarTheme(
        color: isDarkTheme ? const Color.fromARGB(255, 182, 159, 98) : Colors.white,
      ),
      textTheme: TextTheme(
        bodySmall: TextStyle(
          fontSize: 12,
          color: isDarkTheme ? const Color.fromARGB(255, 195, 191, 191) : Colors.black.withOpacity(0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
          // textStyle: const TextStyle(
          //   fontSize: 18,
          //   fontWeight: FontWeight.bold,
          // ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDarkTheme ? const Color.fromARGB(255, 195, 191, 191) : const Color.fromARGB(31, 191, 90, 90),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isDarkTheme ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.greenAccent,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(height: 0),
      ),
    );
  }
}
