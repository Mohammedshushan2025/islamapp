import 'dart:async';
import 'package:islamapp/widgets/custom_digital_clock.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:islamapp/screens/adhkar/adhkar_category_screen.dart';
import 'package:islamapp/screens/hadith/hadith_books_screen.dart';
import 'package:islamapp/screens/prayer_times_screen.dart';
import 'package:islamapp/screens/qibla_screen.dart';
import 'package:islamapp/screens/quran/quran_index_screen.dart';
import 'package:islamapp/services/prayer_times_service.dart';
import 'package:adhan/adhan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  String _locationError = '';
  Prayer? _nextPrayer;
  Duration? _timeUntilNextPrayer;
  Timer? _prayerTimer;

  @override
  void initState() {
    super.initState();
    _setupPrayerTimes();
  }

  @override
  void dispose() {
    _prayerTimer?.cancel();
    super.dispose();
  }

  Future<void> _setupPrayerTimes() async {
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes();
      if (!mounted) return;
      setState(() {
        _prayerTimes = prayerTimes;
        _updateNextPrayerTime();
      });
      // بدء التحديث الدوري كل ثانية
      _prayerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        _updateNextPrayerTime();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
      });
    }
  }

  void _updateNextPrayerTime() {
    if (_prayerTimes == null) return;

    final now = DateTime.now();
    final nextPrayerConstant = _prayerTimes!.nextPrayer();
    final nextPrayerTime = _prayerTimes!.timeForPrayer(nextPrayerConstant);

    if (nextPrayerTime != null &&
        (now.isAfter(nextPrayerTime) ||
            now.isAtSameMomentAs(nextPrayerTime))) {
      // إذا حان الوقت، نعيد حساب المواقيت لليوم الحالي للحصول على الصلاة التالية الصحيحة
      _prayerTimes = PrayerTimes(
          _prayerTimes!.coordinates,
          DateComponents.from(now),
          _prayerTimes!.calculationParameters);
    }

    setState(() {
      _nextPrayer = _prayerTimes!.nextPrayer();
      final timeForNextPrayer = _prayerTimes!.timeForPrayer(_nextPrayer!);
      if (timeForNextPrayer != null) {
        _timeUntilNextPrayer = timeForNextPrayer.difference(now);
      }
    });
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _getPrayerNameInArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return "الفجر";
      case Prayer.sunrise:
        return "الشروق";
      case Prayer.dhuhr:
        return "الظهر";
      case Prayer.asr:
        return "العصر";
      case Prayer.maghrib:
        return "المغرب";
      case Prayer.isha:
        return "العشاء";
      case Prayer.none:
        return "انتهت صلوات اليوم";
    }
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
              const SizedBox(height: 25),

              // --- بطاقة الصلاة ---
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FullPrayerTimesScreen()),
                  );
                },
                child: _buildPrayerCard(),
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

  Widget _buildPrayerCard() {
    if (_locationError.isNotEmpty) {
      return Center(child: Text('خطأ: $_locationError'));
    }
    if (_prayerTimes == null || _nextPrayer == null) {
      return const Center(child: CircularProgressIndicator());
    }

    String prayerName = _getPrayerNameInArabic(_nextPrayer!);

    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: [
              Text(
                'الصلاة التالية: $prayerName',
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 15),
              const CustomDigitalClock(),
              const SizedBox(height: 15),
              if (_timeUntilNextPrayer != null)
                Text(
                  'الوقت المتبقي: ${_formatDuration(_timeUntilNextPrayer!)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
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
        _quickAccessCard('القبلة', Icons.explore_outlined, () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
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