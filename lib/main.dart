import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:islamapp/screens/home_screen.dart';
import 'package:islamapp/utils/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:intl/date_symbol_data_local.dart'; // <-- أضف هذا الاستيراد

void main() async {
  // <-- حول الدالة إلى async
  WidgetsFlutterBinding.ensureInitialized(); // <-- تأكد من تهيئة الفلاتر
  await initializeDateFormatting('ar', null); // <-- قم بتهيئة بيانات اللغة العربية
  HijriCalendar.setLocal('ar');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'نور الإسلام',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            // تحديد اللغة الافتراضية للتطبيق
            locale: const Locale('ar'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'), // اللغة العربية
              Locale('en'), // اللغة الإنجليزية (اختياري)
            ],
            debugShowCheckedModeBanner: false,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}