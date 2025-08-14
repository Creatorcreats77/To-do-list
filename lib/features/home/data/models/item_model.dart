import 'dart:convert';

class ItemModel {
  int? id;
  int categoryId;
  String title;
  String type; // 'button', 'action', 'rule', 'design', 'other'
  Map<dynamic, dynamic> props; // JSON props for preview
  String code;
  String createdAt;
  ItemModel({
    this.id,
    required this.categoryId,
    required this.title,
    required this.type,
    required this.props,
    required this.code,
    required this.createdAt,
  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'type': type,
    'props': jsonEncode(props),
    'code': code,
    'createdAt': createdAt,
  };
  static ItemModel fromMap(Map m) => ItemModel(
    id: m['id'] as int?,
    categoryId: m['categoryId'] as int,
    title: m['title'] as String,
    type: m['type'] as String,
    props: jsonDecode(m['props'] as String) as Map<String, dynamic>,
    code: m['code'] as String,
    createdAt: m['createdAt'] as String,
  );
}