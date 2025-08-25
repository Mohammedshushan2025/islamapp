//
class AdhkarCategory {
  final int id;
  final String category;
  final List<Dhikr> array;

  AdhkarCategory({required this.id, required this.category, required this.array});

  factory AdhkarCategory.fromJson(Map<String, dynamic> json) {
    var list = json['array'] as List;
    List<Dhikr> dhikrList = list.map((i) => Dhikr.fromJson(i)).toList();
    return AdhkarCategory(
      id: json['id'],
      category: json['category'],
      array: dhikrList,
    );
  }
}

class Dhikr {
  final int id;
  final String text;
  final int count;

  Dhikr({required this.id, required this.text, required this.count});

  factory Dhikr.fromJson(Map<String, dynamic> json) {
    return Dhikr(
      id: json['id'],
      text: json['text'],
      count: json['count'],
    );
  }
}