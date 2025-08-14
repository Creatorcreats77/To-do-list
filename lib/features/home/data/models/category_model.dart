class Category {
  int? id;
  String name;
  Category({this.id, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  static Category fromMap(Map m) => Category(id: m['id'] as int?, name: m['name'] as String);
}