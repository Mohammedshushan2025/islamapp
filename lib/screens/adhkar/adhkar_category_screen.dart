import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:islamapp/models/adhkar_model.dart';
import 'package:islamapp/screens/adhkar/dhikr_view_screen.dart';
import 'package:animate_do/animate_do.dart';

class AdhkarCategoryScreen extends StatefulWidget {
  const AdhkarCategoryScreen({super.key});

  @override
  _AdhkarCategoryScreenState createState() => _AdhkarCategoryScreenState();
}

class _AdhkarCategoryScreenState extends State<AdhkarCategoryScreen> {
  Future<List<AdhkarCategory>> _loadAdhkar() async {
    final String response =
    await rootBundle.loadString('assets/json/adhkar.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => AdhkarCategory.fromJson(json)).toList();
  }

  // أيقونات مقترحة لكل فئة
  final List<IconData> categoryIcons = [
    Icons.wb_sunny_outlined,
    Icons.nights_stay_outlined,
    Icons.alarm_on,
    Icons.wc,
    Icons.meeting_room,
    Icons.water_drop_outlined,
    // ... أضف أيقونات لباقي الفئات
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن المسلم'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<AdhkarCategory>>(
        future: _loadAdhkar(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أذكار'));
          }

          final categories = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // عمودان
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2, // نسبة العرض إلى الارتفاع للبطاقة
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return FadeInUp(
                delay: Duration(milliseconds: 100 * index),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DhikrViewScreen(
                            category: category,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          // التأكد من أن الأيقونة موجودة قبل استخدامها
                          index < categoryIcons.length
                              ? categoryIcons[index]
                              : Icons.list_alt_rounded,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            category.category,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}