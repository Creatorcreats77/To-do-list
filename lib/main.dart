// lib/main.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For desktop (macOS, linux, windows) use sqflite_common_ffi
  if (!kIsWeb && (Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
    sqfliteFfiInit(); // initialize ffi
    databaseFactory = databaseFactoryFfi; // set global factory
  }

  // Ensure DB is ready
  await DBHelper.instance.init();
  runApp(ChangeNotifierProvider(create: (_) => AppState()..loadAll(), child: MyApp()));
}

/// ----- Models -----
class Category {
  int? id;
  String name;
  Category({this.id, required this.name});
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  static Category fromMap(Map m) => Category(id: m['id'] as int?, name: m['name'] as String);
}

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

/// ----- DB Helper (singleton) -----
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
          name TEXT UNIQUE
        )
      ''');
      await db.execute('''
        CREATE TABLE items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          categoryId INTEGER,
          title TEXT,
          type TEXT,
          props TEXT,
          code TEXT,
          createdAt TEXT
        )
      ''');
      // Insert a default category
      await db.insert('categories', {'name': 'Buttons'});
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
    else if (themeMode == ThemeMode.dark) themeMode = ThemeMode.system;
    else themeMode = ThemeMode.light;
    notifyListeners();
  }
}

/// ----- UI -----
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp(
      title: 'Flutter Widgets Helper',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: appState.themeMode,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              children: [
                SizedBox(height: 28),
                Text('Categories', style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: app.categories.length,
                    itemBuilder: (c, i) {
                      final cat = app.categories[i];
                      final selected = cat.id == app.selectedCategoryId;
                      return ListTile(
                        selected: selected,
                        title: Text(cat.name),
                        onTap: () => app.selectCategory(cat.id!),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Delete category?'),
                                content: Text('Delete "${cat.name}" and its items?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
                                ],
                              ),
                            );
                            if (ok == true) app.deleteCategory(cat.id!);
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Add category'),
                    onPressed: () async {
                      final name = await _showTextDialog(context, title: 'New category name');
                      if (name != null && name.trim().isNotEmpty) {
                        await app.addCategory(name.trim());
                      }
                    },
                  ),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),

          // Main area
          Expanded(
            child: Column(
              children: [
                // Top bar
                Container(
                  height: 64,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(app.categories.firstWhere((c) => c.id == app.selectedCategoryId, orElse: () => Category(id: 0, name: '—')).name,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Spacer(),
                      IconButton(
                        tooltip: 'Toggle theme (light/dark/system)',
                        icon: Icon(Icons.brightness_6),
                        onPressed: () => app.toggleTheme(),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: Icon(Icons.add),
                        label: Text('Add item'),
                        onPressed: () {
                          if (app.selectedCategoryId == null) return;
                          showDialog(
                            context: context,
                            builder: (_) => ItemEditorDialog(
                              categoryId: app.selectedCategoryId!,
                              onSaved: (item) => app.addOrUpdateItem(item),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Consumer<AppState>(
                    builder: (context, s, _) {
                      if (s.items.isEmpty) {
                        return Center(child: Text('No items. Click "Add item" to create one.'));
                      }
                      return GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 420,
                          mainAxisExtent: 120,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: s.items.length,
                        itemBuilder: (ctx, i) {
                          final it = s.items[i];
                          return Card(
                            child: InkWell(
                              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(item: it))),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  children: [
                                    Expanded(child: PreviewWidget(item: it)),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(it.title, style: Theme.of(context).textTheme.titleMedium),
                                          SizedBox(height: 8),
                                          Text('Type: ${it.type}'),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.edit),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => ItemEditorDialog(
                                                      categoryId: it.categoryId,
                                                      item: it,
                                                      onSaved: (newItem) => s.addOrUpdateItem(newItem),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.delete_outline),
                                                onPressed: () async {
                                                  final ok = await showDialog<bool>(
                                                    context: context,
                                                    builder: (ctx) => AlertDialog(
                                                      title: Text('Delete item?'),
                                                      actions: [
                                                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel')),
                                                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Delete')),
                                                      ],
                                                    ),
                                                  );
                                                  if (ok == true) s.deleteItem(it.id!);
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small preview -- for 'button' type we render an ElevatedButton with label from props
class PreviewWidget extends StatelessWidget {
  final ItemModel item;
  const PreviewWidget({required this.item});
  @override
  Widget build(BuildContext context) {
    final props = item.props;
    if (item.type.toLowerCase() == 'button') {
      final label = props['label'] ?? item.title;
      return Center(
        child: ElevatedButton(onPressed: () {}, child: Text(label)),
      );
    }
    // fallback preview
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 6),
        Text(item.type),
        SizedBox(height: 8),
        Expanded(child: SingleChildScrollView(child: Text(jsonEncode(item.props)))),
      ],
    );
  }
}

/// Item detail page: preview up top, code viewer below
class ItemDetailPage extends StatelessWidget {
  final ItemModel item;
  ItemDetailPage({required this.item});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: Column(
        children: [
          Container(height: 160, padding: EdgeInsets.all(12), child: PreviewWidget(item: item)),
          Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: HighlightView(
                item.code.isEmpty ? '// No code provided' : item.code,
                language: 'dart',
                theme: githubTheme,
                padding: EdgeInsets.all(12),
                textStyle: TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog to create or edit an item
class ItemEditorDialog extends StatefulWidget {
  final int categoryId;
  final ItemModel? item;
  final Future<void> Function(ItemModel) onSaved;
  ItemEditorDialog({required this.categoryId, this.item, required this.onSaved});
  @override
  _ItemEditorDialogState createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _type;
  String _label = '';
  late String _code;

  @override
  void initState() {
    super.initState();
    _title = widget.item?.title ?? '';
    _type = widget.item?.type ?? 'button';
    _label = widget.item?.props['label'] ?? '';
    _code = widget.item?.code ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New item' : 'Edit item'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(initialValue: _title, decoration: InputDecoration(labelText: 'Title'), onSaved: (v) => _title = v ?? ''),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _type,
                items: ['button', 'action', 'rule', 'design', 'other'].map((t) => DropdownMenuItem(child: Text(t), value: t)).toList(),
                onChanged: (v) => setState(() => _type = v ?? 'button'),
                decoration: InputDecoration(labelText: 'Type'),
              ),
              SizedBox(height: 8),
              if (_type == 'button')
                TextFormField(initialValue: _label, decoration: InputDecoration(labelText: 'Button label'), onSaved: (v) => _label = v ?? ''),
              SizedBox(height: 12),
              TextFormField(
                initialValue: _code,
                decoration: InputDecoration(labelText: 'Code (Dart/Flutter)'),
                maxLines: 8,
                onSaved: (v) => _code = v ?? '',
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            _formKey.currentState!.save();
            final now = DateTime.now().toIso8601String();
            final props = _type == 'button' ? {'label': _label} : {};
            final newItem = ItemModel(
              id: widget.item?.id,
              categoryId: widget.categoryId,
              title: _title,
              type: _type,
              props: props,
              code: _code,
              createdAt: widget.item?.createdAt ?? now,
            );
            await widget.onSaved(newItem);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

/// small helper dialog to input a single text
Future<String?> _showTextDialog(BuildContext context, {required String title}) async {
  final _controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, null), child: Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, _controller.text), child: Text('OK')),
      ],
    ),
  );
}
