import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:islamapp/models/quran_model.dart';

class QuranService {
  Future<Surah> loadSurah(int surahNumber) async {
    final String response = await rootBundle.loadString('assets/json/surahs/surah_$surahNumber.json');
    final data = await json.decode(response);
    return Surah.fromJson(data);
  }
}