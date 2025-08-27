import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamapp/screens/adhkar/adhkar_category_screen.dart';
import 'package:islamapp/screens/hadith/hadith_books_screen.dart';


import 'package:islamapp/screens/quran/quran_index_screen.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Timer? _prayerTimer;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _prayerTimer?.cancel();
    super.dispose();
  }





  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }



  @override
  Widget build(BuildContext context) {
    // --- حساب التاريخ الهجري ---
    final hijriDate = HijriCalendar.now();
    final hijriDateFormatted =
        "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ";

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- عرض التاريخين معًا ---
              FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMMEEEEd('ar').format(DateTime.now()),
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0A5448)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hijriDateFormatted,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- أقسام الوصول السريع ---
              FadeInUp(
                  delay: const Duration(milliseconds: 600),
                  child: _buildQuickAccessGrid()),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _quickAccessCard('القرآن الكريم', Icons.menu_book_rounded, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const QuranIndexScreen()));
        }),
        _quickAccessCard('الأذكار', Icons.wb_sunny_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AdhkarCategoryScreen()));
        }),
        _quickAccessCard('الأحاديث', Icons.book_outlined, () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const HadithBooksScreen()));
        }),
      ],
    );
  }

  Widget _quickAccessCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(title,
                style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}