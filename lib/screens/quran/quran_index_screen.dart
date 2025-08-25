import 'package:flutter/material.dart';
import 'package:islamapp/models/quran_model.dart';
import 'package:islamapp/screens/quran/surah_detail_screen.dart';
import 'package:islamapp/services/quran_service.dart';
import 'package:islamapp/utils/quran_constants.dart';
import 'package:islamapp/widgets/quran_juz_list.dart';

class QuranIndexScreen extends StatefulWidget {
  const QuranIndexScreen({super.key});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
          indicatorColor: Theme.of(context).primaryColor,
          indicatorWeight: 3,
          labelColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'السور'),
            Tab(text: 'الأجزاء'),
          ],
        ),
      ),
      body: Container(
        // إضافة خلفية بنقش إسلامي خفيف
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/islamic_bg.png"), // <-- أنشئ صورة نقش وضعها هنا
            fit: BoxFit.cover,
            opacity: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.1,
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSurahList(),
            const QuranJuzList(), // يمكنك تصميمها بنفس طريقة السور
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
    final QuranService quranService = QuranService();
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 114,
      itemBuilder: (context, index) {
        // بيانات إضافية للسورة (مؤقتة لحين إكمال القائمة)
        final metadata = surahMetadata.length > index
            ? surahMetadata[index]
            : {"revelationType": "مكية", "verseCount": 0};

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              try {
                Surah surah = await quranService.loadSurah(index + 1);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SurahDetailScreen(surah: surah),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ في تحميل السورة: ${e.toString()}')),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // --- شكل رقم السورة ---
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // --- اسم السورة وبياناتها ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${surahNames[index]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${metadata["revelationType"]} - ${metadata["verseCount"]} آيات',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // --- أيقونة الانتقال ---
                  Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}