//
class Hadith {
  final int number;
  final String hadithText;
  final String? description;
  final String? searchTerm;

  Hadith({
    required this.number,
    required this.hadithText,
    this.description,
    this.searchTerm,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      number: json['number'],
      hadithText: json['hadith'],
      description: json['description'],
      searchTerm: json['searchTerm'],
    );
  }
}