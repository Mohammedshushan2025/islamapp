


import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:islamapp/models/quran_model.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/quran_constants.dart';

// enum لتحديد حالة تشغيل الصوت بشكل دقيق
enum PlayerState { stopped, loading, playing, paused }

class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? startingVerseIndex;

  const SurahDetailScreen({
    super.key,
    required this.surah,
    this.startingVerseIndex,
  });

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  final Set<int> _bookmarkedVerses = {};

  // متغيرات حالة الصوت
  PlayerState _playerState = PlayerState.stopped;
  int? _currentlyPlayingIndex;
  double _fontSize = 24.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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
          // عند التوقف أو الانتهاء أو الخطأ
          _playerState = PlayerState.stopped;
          _currentlyPlayingIndex = null;
        }
      });
    });
  }

  Future<void> _handlePlayPause(int index, int verseNumber) async {
    // إذا ضغط على زر الإيقاف المؤقت
    if (_currentlyPlayingIndex == index && _playerState == PlayerState.playing) {
      await _audioPlayer.pause();
      return;
    }
    // إذا ضغط على زر استئناف التشغيل
    if (_currentlyPlayingIndex == index && _playerState == PlayerState.paused) {
      await _audioPlayer.resume();
      return;
    }

    // إذا ضغط على زر تشغيل لآية جديدة
    setState(() {
      _currentlyPlayingIndex = index;
      _playerState = PlayerState.loading; // <-- عرض علامة التحميل
    });

    try {
      String surahIndexPadded = widget.surah.index.padLeft(3, '0');
      String verseNumberPadded = verseNumber.toString().padLeft(3, '0');
      String audioUrl = "https://www.everyayah.com/data/Minshawy_Mujawwad_192kbps/$surahIndexPadded$verseNumberPadded.mp3";
      await _audioPlayer.play(ap.UrlSource(audioUrl));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playerState = PlayerState.stopped;
        _currentlyPlayingIndex = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تحميل الملف الصوتي. يرجى التحقق من اتصالك بالإنترنت.')));
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('quran_font_size') ?? 24.0;
      final surahBookmarks = prefs.getStringList('bookmark_${widget.surah.index}') ?? [];
      _bookmarkedVerses.addAll(surahBookmarks.map((e) => int.tryParse(e) ?? -1));
    });

    if (widget.startingVerseIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScrollController.isAttached) {
          _itemScrollController.scrollTo(
            index: widget.startingVerseIndex!,
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  Future<void> _toggleBookmark(int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_bookmarkedVerses.contains(verseIndex)) {
        _bookmarkedVerses.remove(verseIndex);
      } else {
        _bookmarkedVerses.add(verseIndex);
      }
    });
    await prefs.setStringList(
      'bookmark_${widget.surah.index}',
      _bookmarkedVerses.map((e) => e.toString()).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // الكود هنا لم يتغير
    final bismillah = widget.surah.verse.containsKey('verse_0') ? widget.surah.verse['verse_0'] : null;
    final verses = widget.surah.verse.entries.where((entry) => entry.key != 'verse_0').toList();
    final arabicSurahName = surahNames[int.parse(widget.surah.index) - 1];
    return Scaffold(

      appBar: AppBar(title: Text('سورة ${arabicSurahName}')),
      body: ScrollablePositionedList.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemScrollController: _itemScrollController,
        itemCount: verses.length,
        itemBuilder: (context, index) {
          final verseEntry = verses[index];
          final verseNumber = int.parse(verseEntry.key.split('_')[1]);
          final cleanVerseText = verseEntry.value;

          return _QuranVerseWidget(
            verseText: cleanVerseText,
            verseNumber: verseNumber,
            isBookmarked: _bookmarkedVerses.contains(index),
            playerState: _currentlyPlayingIndex == index ? _playerState : PlayerState.stopped,
            onPlayPause: () => _handlePlayPause(index, verseNumber),
            onBookmark: () => _toggleBookmark(index),
            fontSize: _fontSize,
          );
        },
      ),
    );
  }
}

/// ويدجت داخلي لعرض الآية بشكل موحد وأنيق
class _QuranVerseWidget extends StatelessWidget {
  final String verseText;
  final int verseNumber;
  final bool isBookmarked;
  final PlayerState playerState;
  final double fontSize;
  final VoidCallback onPlayPause;
  final VoidCallback onBookmark;

  const _QuranVerseWidget({
    required this.verseText,
    required this.verseNumber,
    required this.isBookmarked,
    required this.playerState,
    required this.fontSize,
    required this.onPlayPause,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: playerState != PlayerState.stopped
            ? Theme.of(context).primaryColor.withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: playerState != PlayerState.stopped
              ? Theme.of(context).primaryColor.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Uthmanic',
                fontSize: fontSize,
                height: 2.2,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              children: [
                TextSpan(text: verseText),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(
                          "assets/images/verse_end_icon.png",
                          width: 40,
                          height: 40,
                          color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                        ),
                        Text(
                          '$verseNumber',
                          style: const TextStyle(
                            fontSize: 12,
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                // -->> التعديل الأول هنا <<--
                icon: _buildPlayerIcon(context),
                onPressed: onPlayPause,
                iconSize: 32,
                color: Theme.of(context).primaryColor,
              ),
              IconButton(
                icon: Icon(
                  isBookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                ),
                onPressed: onBookmark,
                iconSize: 30,
                color: Theme.of(context).primaryColor,
              ),
            ],
          )
        ],
      ),
    );
  }

  // -->> التعديل الثاني هنا <<--
  Widget _buildPlayerIcon(BuildContext context) {
    switch (playerState) {
      case PlayerState.loading:
        return SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: Theme.of(context).primaryColor)); // الآن يمكنها الوصول للـ Theme
      case PlayerState.playing:
        return const Icon(Icons.pause_circle_filled_rounded);
      case PlayerState.paused:
        return const Icon(Icons.play_circle_fill_rounded);
      case PlayerState.stopped:
        return const Icon(Icons.play_circle_outline_rounded);
    }
  }
}