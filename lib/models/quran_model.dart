//
class Surah {
  final String index;
  final String name;
  final Map<String, String> verse;
  final int count;
  final List<Juz> juz;

  Surah({
    required this.index,
    required this.name,
    required this.verse,
    required this.count,
    required this.juz,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      index: json['index'],
      name: json['name'],
      verse: Map<String, String>.from(json['verse']),
      count: json['count'],
      juz: (json['juz'] as List).map((i) => Juz.fromJson(i)).toList(),
    );
  }
}

class Juz {
  final String index;
  final VerseRange verse;

  Juz({required this.index, required this.verse});

  factory Juz.fromJson(Map<String, dynamic> json) {
    return Juz(
      index: json['index'],
      verse: VerseRange.fromJson(json['verse']),
    );
  }
}

class VerseRange {
  final String start;
  final String end;

  VerseRange({required this.start, required this.end});

  factory VerseRange.fromJson(Map<String, dynamic> json) {
    return VerseRange(
      start: json['start'],
      end: json['end'],
    );
  }
}