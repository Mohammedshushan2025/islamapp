import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:islamapp/models/juz_model.dart';
import 'package:islamapp/models/quran_model.dart';
import 'package:islamapp/services/quran_service.dart';
import 'package:islamapp/utils/quran_constants.dart';
import 'package:islamapp/widgets/quran_verse_widget.dart';

// كلاسات لتمثيل العناصر في القائمة
abstract class JuzListItem {}

class SurahHeaderItem implements JuzListItem {
  final String surahName;
  SurahHeaderItem(this.surahName);
}

class VerseItem implements JuzListItem {
  final int surahNumber;
  final int verseNumber;
  final String verseText;
  VerseItem(this.surahNumber, this.verseNumber, this.verseText);
}

class JuzViewScreen extends StatefulWidget {
  final JuzInfo juzInfo;
  const JuzViewScreen({super.key, required this.juzInfo});

  @override
  State<JuzViewScreen> createState() => _JuzViewScreenState();
}

class _JuzViewScreenState extends State<JuzViewScreen> {
  late Future<List<JuzListItem>> _juzVersesFuture;
  final QuranService _quranService = QuranService();
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();

  PlayerState _playerState = PlayerState.stopped;
  String? _currentlyPlayingId; // ID فريد للآية الحالية (مثال: "2_142")

  @override
  void initState() {
    super.initState();
    _juzVersesFuture = _loadJuzVerses();
    _setupAudioPlayerListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state == ap.PlayerState.playing) {
          _playerState = PlayerState.playing;
        } else if (state == ap.PlayerState.paused) {
          _playerState = PlayerState.paused;
        } else {
          _playerState = PlayerState.stopped;
          _currentlyPlayingId = null;
        }
      });
    });
  }

  Future<void> _handlePlayPause(int surahNum, int verseNum) async {
    final currentId = '${surahNum}_$verseNum';
    if (_currentlyPlayingId == currentId && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }
    if (_currentlyPlayingId == currentId && _playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    setState(() {
      _currentlyPlayingId = currentId;
      _playerState = PlayerState.loading;
    });

    try {
      String surahIndexPadded = surahNum.toString().padLeft(3, '0');
      String verseNumberPadded = verseNum.toString().padLeft(3, '0');
      String audioUrl = "https://www.everyayah.com/data/Minshawy_Mujawwad_192kbps/$surahIndexPadded$verseNumberPadded.mp3";
      await _audioPlayer.play(ap.UrlSource(audioUrl));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playerState = PlayerState.stopped;
        _currentlyPlayingId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تحميل الملف الصوتي.')));
    }
  }

  Future<List<JuzListItem>> _loadJuzVerses() async {
    List<JuzListItem> items = [];
    for (int surahNum = widget.juzInfo.startSurah; surahNum <= widget.juzInfo.endSurah; surahNum++) {
      Surah surahData = await _quranService.loadSurah(surahNum);
      items.add(SurahHeaderItem(surahNames[surahNum - 1]));

      if (surahNum != 1 && surahNum != 9) {
        items.add(VerseItem(surahNum, 0, "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"));
      }

      int startAyah = (surahNum == widget.juzInfo.startSurah) ? widget.juzInfo.startAyah : 1;
      int endAyah = (surahNum == widget.juzInfo.endSurah) ? widget.juzInfo.endAyah : surahData.count;

      for (int ayahNum = startAyah; ayahNum <= endAyah; ayahNum++) {
        final verseKey = 'verse_$ayahNum';
        if (surahData.verse.containsKey(verseKey)) {
          items.add(VerseItem(surahNum, ayahNum, surahData.verse[verseKey]!));
        }
      }
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الجزء ${widget.juzInfo.juz}')),
      body: FutureBuilder<List<JuzListItem>>(
        future: _juzVersesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("خطأ في التحميل: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("لا توجد بيانات"));
          }

          final items = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              // -->> هذا هو الكود الكامل الذي كان ناقصًا <<--

              // 1. عرض فاصل السورة
              if (item is SurahHeaderItem) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.only(bottom: 10, top: 10),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const AssetImage("assets/images/surah_header_bg.png"),
                      fit: BoxFit.fill,
                      colorFilter: ColorFilter.mode(
                        Theme.of(context).primaryColor.withOpacity(0.8),
                        BlendMode.srcATop,
                      ),
                    ),
                  ),
                  child: Text(
                    "سورة ${item.surahName}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontFamily: 'Uthmanic',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                );
              }

              // 2. عرض الآيات والبسملة
              if (item is VerseItem) {
                // عرض البسملة بشكل خاص
                if (item.verseNumber == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      item.verseText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: 'Uthmanic', fontSize: 22),
                    ),
                  );
                }

                // عرض الآية العادية باستخدام الويدجت الموحد
                final currentId = '${item.surahNumber}_${item.verseNumber}';
                return QuranVerseWidget(
                  verseText: item.verseText,
                  verseNumber: item.verseNumber,
                  isBookmarked: false, // الحفظ غير مفعل في وضع الجزء حاليا
                  playerState: _currentlyPlayingId == currentId ? _playerState : PlayerState.stopped,
                  onPlayPause: () => _handlePlayPause(item.surahNumber, item.verseNumber),
                  onBookmark: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الحفظ متاح في وضع السور فقط حاليًا.')));
                  },
                );
              }

              // كود احتياطي (لا يجب أن يصل هنا)
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}