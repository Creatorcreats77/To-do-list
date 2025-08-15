import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/category_model.dart';
import '../models/item_model.dart';

class DBHelper {
  DBHelper._private();
  static final DBHelper instance = DBHelper._private();
  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'widget_helper.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT 
        )
      ''');
      await db.execute('''
        CREATE TABLE items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          categoryId INTEGER,
          title TEXT,
          text TEXT,
          createdAt TEXT
        )
      ''');
    });
  }

  Future<List<Category>> getCategories() async {
    final db = _db!;
    final rows = await db.query('categories', orderBy: 'name');
    return rows.map((r) => Category.fromMap(r)).toList();
  }

  Future<int> insertCategory(String name) async {
    final db = _db!;
    return await db.insert('categories', {'name': name});
  }

  Future<int> updateCategory(Category c) async {
    final db = _db!;
    return await db.update('categories', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = _db!;
    // delete items first (simple strategy)
    await db.delete('items', where: 'categoryId = ?', whereArgs: [id]);
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertItem(ItemModel item) async {
    print("item to map  aaaaaaaaaaaaaaaaaa: ${item.toMap()}");
    final db = _db!;
    return await db.insert('items', item.toMap());
  }

  Future<int> updateItem(ItemModel item) async {
    final db = _db!;
    return await db.update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  Future<int> deleteItem(int id) async {
    final db = _db!;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ItemModel>> getItemsByCategory(int categoryId) async {
    final db = _db!;
    final rows = await db.query('items', where: 'categoryId = ?', whereArgs: [categoryId], orderBy: 'createdAt DESC');
    return rows.map((r) => ItemModel.fromMap(r)).toList();
  }
}

/// ----- App State (Provider) -----
class AppState extends ChangeNotifier {
  List<Category> categories = [];
  int? selectedCategoryId;
  List<ItemModel> items = [];
  ThemeMode themeMode = ThemeMode.system;

  Future<void> loadAll() async {
    categories = await DBHelper.instance.getCategories();
    if (categories.isEmpty) {
      await DBHelper.instance.insertCategory('Buttons');
      categories = await DBHelper.instance.getCategories();
    }
    selectedCategoryId ??= categories.first.id;
    await loadItems();
    notifyListeners();
  }

  Future<void> loadItems() async {
    if (selectedCategoryId == null) {
      items = [];
    } else {
      items = await DBHelper.instance.getItemsByCategory(selectedCategoryId!);
    }
    notifyListeners();
  }

  // Creats category name you give
  Future<void> addCategory(String name) async {
    await DBHelper.instance.insertCategory(name);
    await loadAll();
  }

  Future<void> deleteCategory(int id) async {
    await DBHelper.instance.deleteCategory(id);
    if (selectedCategoryId == id) selectedCategoryId = categories.isNotEmpty ? categories.first.id : null;
    await loadAll();
  }

  Future<void> selectCategory(int id) async {
    selectedCategoryId = id;
    await loadItems();
  }

  Future<void> addOrUpdateItem(ItemModel item) async {
    print("weeeeeeeeeeeeeeeee: ${item.id}");
    if (item.id == null) {
      await DBHelper.instance.insertItem(item);
    } else {
      await DBHelper.instance.updateItem(item);
    }
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await DBHelper.instance.deleteItem(id);
    await loadItems();
  }

  void toggleTheme() {
    if (themeMode == ThemeMode.light) themeMode = ThemeMode.dark;
    else themeMode = ThemeMode.light;
    notifyListeners();
  }
}