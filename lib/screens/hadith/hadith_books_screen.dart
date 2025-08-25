import 'package:flutter/material.dart';
import 'package:islamapp/screens/hadith/hadith_list_screen.dart';
import 'package:animate_do/animate_do.dart';

class HadithBooksScreen extends StatelessWidget {
  const HadithBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hadithBooks = {
      'صحيح البخاري': 'bukhari',
      'صحيح مسلم': 'muslim',
      'مسند أحمد': 'ahmed',
      'جامع الترمذي': 'trmizi',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('كتب الأحاديث'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: hadithBooks.length,
        itemBuilder: (context, index) {
          final bookTitle = hadithBooks.keys.elementAt(index);
          final bookFileName = hadithBooks.values.elementAt(index);
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                leading: Icon(Icons.menu_book_rounded, color: Theme.of(context).primaryColor, size: 30),
                title: Text(bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HadithListScreen(
                        bookTitle: bookTitle,
                        bookFileName: bookFileName,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}