import 'package:flutter/material.dart';

// enum لتحديد حالة تشغيل الصوت
enum PlayerState { stopped, loading, playing, paused }

class QuranVerseWidget extends StatelessWidget {
  final String verseText;
  final int verseNumber;
  final bool isBookmarked;
  final PlayerState playerState;
  final VoidCallback onPlayPause;
  final VoidCallback onBookmark;

  const QuranVerseWidget({
    super.key,
    required this.verseText,
    required this.verseNumber,
    required this.isBookmarked,
    required this.playerState,
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
          // --- نص الآية ---
          RichText(
            textAlign: TextAlign.right,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Uthmanic',
                fontSize: 24, // يمكنك ربطه بـ Provider لاحقًا
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
                            color: Colors.green, // لون النص داخل الأيقونة
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
          // --- شريط الأدوات (تشغيل وحفظ) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: _buildPlayerIcon(),
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

  // دالة لاختيار الأيقونة المناسبة لحالة المشغل
  Widget _buildPlayerIcon() {
    switch (playerState) {
      case PlayerState.loading:
        return const SizedBox(
            width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2));
      case PlayerState.playing:
        return const Icon(Icons.pause_circle_filled_rounded);
      case PlayerState.paused:
        return const Icon(Icons.play_circle_fill_rounded);
      case PlayerState.stopped:
        return const Icon(Icons.play_circle_outline_rounded);
    }
  }
}