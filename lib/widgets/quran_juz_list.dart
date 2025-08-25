import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islamapp/models/juz_model.dart';
import 'package:islamapp/screens/quran/juz_view_screen.dart';

class QuranJuzList extends StatelessWidget {
  const QuranJuzList({super.key});

  // دالة لتحميل بيانات الأجزاء من الملف المحدّث
  Future<List<JuzInfo>> _loadJuzMap() async {
    final String response = await rootBundle.loadString('assets/json/quran_juz_map.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => JuzInfo.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<JuzInfo>>(
      future: _loadJuzMap(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("لا توجد بيانات للأجزاء"));
        }

        final juzList = snapshot.data!;
        return ListView.builder(
          itemCount: juzList.length,
          itemBuilder: (context, index) {
            final juzInfo = juzList[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${juzInfo.juz}'),
                ),
                title: Text('الجزء ${juzInfo.juz}'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // تحديث الانتقال ليفتح شاشة عرض الجزء الجديدة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JuzViewScreen(
                        juzInfo: juzInfo,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}