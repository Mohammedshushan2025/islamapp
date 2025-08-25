import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDigitalClock extends StatefulWidget {
  const CustomDigitalClock({super.key});

  @override
  _CustomDigitalClockState createState() => _CustomDigitalClockState();
}

class _CustomDigitalClockState extends State<CustomDigitalClock> {
  late Timer _timer;
  late DateTime _dateTime;

  @override
  void initState() {
    super.initState();
    _dateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _dateTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تنسيق الوقت لعرض الساعة والدقيقة
    final timeFormatter = DateFormat('hh:mm', 'ar');
    // تنسيق لعرض الثواني
    final secondFormatter = DateFormat('ss', 'ar');
    // تنسيق لعرض صباحًا/مساءً
    final amPmFormatter = DateFormat('a', 'ar');

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Text(
          timeFormatter.format(_dateTime),
          style: const TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          secondFormatter.format(_dateTime),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amPmFormatter.format(_dateTime),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}