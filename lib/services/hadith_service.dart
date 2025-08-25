import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:islamapp/models/hadith_model.dart';

class HadithService {
  Future<List<Hadith>> loadHadithBook(String bookFileName) async {
    final String response = await rootBundle.loadString('assets/json/hadith/$bookFileName.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Hadith.fromJson(json)).toList();
  }
}