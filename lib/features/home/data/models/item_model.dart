
import 'dart:convert';

class ItemModel {
  int? id;
  int categoryId;
  String title;
  String text;
  int? isDone;
  String createdAt;


  String? reminderAt;       // single DateTime if one-time reminder
  List<String>? repeatDays; // ["Mon", "Wed", "Fri"]
  String? reminderTime;     // HH:mm, the time to remind for repeated days

  ItemModel({
    this.id,
    required this.categoryId,
    required this.title,
    required this.text,
    this.isDone,
    required this.createdAt,

    this.reminderAt,
    this.repeatDays,
    this.reminderTime,

  });
  Map<String, dynamic> toMap() => {
    'id': id,
    'categoryId': categoryId,
    'title': title,
    'text': text,
    'isDone': isDone ?? 0,
    'createdAt': createdAt,
    'reminderAt': reminderAt,
    'repeatDays': repeatDays != null ? jsonEncode(repeatDays) : null,
    'reminderTime': reminderTime,
  };

  static ItemModel fromMap(Map m) => ItemModel(
    id: m['id'] as int?,
    categoryId: m['categoryId'] as int,
    isDone: m['isDone'] as int?,
    title: m['title'] as String,
    text: m['text'] as String,
    createdAt: m['createdAt'] as String,
    reminderAt: m['reminderAt'] as String?,
    repeatDays: m['repeatDays'] != null
        ? List<String>.from(jsonDecode(m['repeatDays']))
        : null,
    reminderTime: m['reminderTime'] as String?,
  );
}