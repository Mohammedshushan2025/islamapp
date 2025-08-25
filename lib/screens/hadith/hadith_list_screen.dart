import 'package:flutter/material.dart';
import 'package:islamapp/models/hadith_model.dart';
import 'package:islamapp/services/hadith_service.dart';
import 'package:islamapp/widgets/favorite_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:animate_do/animate_do.dart';

class HadithListScreen extends StatelessWidget {
  final String bookTitle;
  final String bookFileName;
  final HadithService _hadithService = HadithService();

  HadithListScreen({super.key, required this.bookTitle, required this.bookFileName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookTitle),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Hadith>>(
        future: _hadithService.loadHadithBook(bookFileName),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ في تحميل الأحاديث: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد أحاديث في هذا الكتاب'));
          }

          final hadiths = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: hadiths.length,
            itemBuilder: (context, index) {
              final hadith = hadiths[index];
              final shareText = "الحديث رقم ${hadith.number} من $bookTitle:\n\n${hadith.hadithText}";

              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الحديث رقم: ${hadith.number}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(height: 20),
                        Text(
                          hadith.hadithText,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontSize: 18, height: 1.8),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FavoriteButton(
                              identifier: 'hadith_${bookFileName}_${hadith.number}',
                              content: hadith.hadithText,
                            ),
                            IconButton(
                              icon: Icon(Icons.share_outlined, color: Colors.grey.shade600),
                              onPressed: () {
                                Share.share(shareText);
                              },
                            ),
                          ],
                        )
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