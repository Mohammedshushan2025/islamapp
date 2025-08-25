import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';
import 'package:islamapp/services/prayer_times_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hijri/hijri_calendar.dart';

class FullPrayerTimesScreen extends StatefulWidget {
  const FullPrayerTimesScreen({super.key});

  @override
  _FullPrayerTimesScreenState createState() => _FullPrayerTimesScreenState();
}

class _FullPrayerTimesScreenState extends State<FullPrayerTimesScreen> {
  final PrayerTimesService _prayerTimesService = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  String _locationError = '';

  @override
  void initState() {
    super.initState();
    _setupPrayerTimes();
  }

  Future<void> _setupPrayerTimes() async {
    try {
      final prayerTimes = await _prayerTimesService.getPrayerTimes();
      if (!mounted) return;
      setState(() {
        _prayerTimes = prayerTimes;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString();
      });
    }
  }

  String _getPrayerNameInArabic(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr: return "الفجر";
      case Prayer.sunrise: return "الشروق";
      case Prayer.dhuhr: return "الظهر";
      case Prayer.asr: return "العصر";
      case Prayer.maghrib: return "المغرب";
      case Prayer.isha: return "العشاء";
      case Prayer.none: return "انتهت صلوات اليوم";
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحويل التاريخ الميلادي إلى هجري
    final hijriDate = HijriCalendar.now();
    final hijriDateFormatted =
        "${hijriDate.hDay} ${hijriDate.longMonthName} ${hijriDate.hYear} هـ";

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        centerTitle: true,
      ),
      body: _locationError.isNotEmpty
          ? Center(child: Text('خطأ: $_locationError'))
          : _prayerTimes == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- بطاقة التاريخ الهجري ---
            FadeInDown(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16, horizontal: 24),
                  child: Text(
                    hijriDateFormatted,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // --- قائمة الصلوات ---
            _buildPrayersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayersList() {
    final prayers = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha
    ];
    final currentPrayer = _prayerTimes!.currentPrayer();

    return ListView.separated(
      itemCount: prayers.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final prayer = prayers[index];
        final prayerTime = _prayerTimes!.timeForPrayer(prayer)!;
        final isCurrentPrayer = prayer == currentPrayer;

        return FadeInUp(
          delay: Duration(milliseconds: 100 * (index + 1)),
          child: Card(
            elevation: isCurrentPrayer ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: BorderSide(
                color: isCurrentPrayer
                    ? Theme.of(context).primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              leading: Icon(
                Icons.timer_outlined,
                color: isCurrentPrayer
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                size: 30,
              ),
              title: Text(
                _getPrayerNameInArabic(prayer),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isCurrentPrayer
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              trailing: Text(
                DateFormat.jm('ar').format(prayerTime),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}