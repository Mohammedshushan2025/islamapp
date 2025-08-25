import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppThemes {
  // الوضع الفاتح - فجر المدينة
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F5F1), // كريمي
    primaryColor: const Color(0xFF0A5448), // أخضر زمردي
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: const Color(0xFF3A3A3A), // بني محروق
      displayColor: const Color(0xFF3A3A3A),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8F5F1),
      elevation: 0.5,
      iconTheme: IconThemeData(color: Color(0xFF0A5448)),
      titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          color: Color(0xFF0A5448), // أخضر
          fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0A5448), // أخضر
      unselectedItemColor: Colors.grey,
      elevation: 5,
    ),
    // هذا هو الكود الصحيح لـ CardTheme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  // الوضع الداكن - ليالي مكة
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212), // أسود فحمي
    primaryColor: const Color(0xFFD4AF37), // ذهبي
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: const Color(0xFFE0E0E0), // فضي
      displayColor: const Color(0xFFE0E0E0),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFD4AF37)),
      titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          color: Color(0xFFD4AF37), // ذهبي
          fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1F1F),
      selectedItemColor: Color(0xFFD4AF37), // ذهبي
      unselectedItemColor: Colors.grey,
      elevation: 5,
    ),
    // هذا هو الكود الصحيح لـ CardTheme
    cardTheme: CardThemeData(
      color: const Color(0xFF1F1F1F),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}