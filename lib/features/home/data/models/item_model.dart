
class ItemModel {
  int? id;
  int categoryId;
  String title;
  String text;
  int? isDone;
  String createdAt;
  ItemModel({
    this.id,
    required this.categoryId,
    required this.title,
    required this.text,
    this.isDone,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'text': text,
    'isDone' : isDone ?? 0,
    'createdAt': createdAt,
  };
  static ItemModel fromMap(Map m) => ItemModel(
    id: m['id'] as int?,
    categoryId: m['categoryId'] as int,
    isDone: m['isDone'] as int?,
    title: m['title'] as String,
    text: m['text'] as String,
    createdAt: m['createdAt'] as String,
  );
}