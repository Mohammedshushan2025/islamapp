class JuzInfo {
  final int juz;
  final int startSurah;
  final int startAyah;
  final int endSurah;
  final int endAyah;

  JuzInfo({
    required this.juz,
    required this.startSurah,
    required this.startAyah,
    required this.endSurah,
    required this.endAyah,
  });

  factory JuzInfo.fromJson(Map<String, dynamic> json) {
    return JuzInfo(
      juz: json['juz'],
      startSurah: json['start_surah'],
      startAyah: json['start_ayah'],
      endSurah: json['end_surah'],
      endAyah: json['end_ayah'],
    );
  }
}