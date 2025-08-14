import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/db_helper.dart';
import '../widgets/prewiev_widget.dart';
import 'item_detail_page.dart';
import 'item_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _sidebar = false;
  bool _appBar = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    print(size);
    final app = Provider.of<AppState>(context);
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // Sidebar
            ?_sidebar
                ? Container(
                    width: 260,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Categories',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              ?size < 600
                                  ? IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _sidebar = !_sidebar;
                                          if (size < 600) {
                                            _appBar = !_appBar;
                                          }
                                        });
                                      },
                                      icon: Icon(Icons.list),
                                    )
                                  : null,
                            ],
                          ),
                        ),
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
                                        content: Text(
                                          'Delete "${cat.name}" and its items?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text('Delete'),
                                          ),
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
                              final name = await _showTextDialog(
                                context,
                                title: 'New category name',
                              );
                              if (name != null && name.trim().isNotEmpty) {
                                await app.addCategory(name.trim());
                              }
                            },
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  )
                : null,

            // Main area
            Expanded(
              child: Column(
                children: [
                  // Top bar
                  ?_appBar
                      ? Container(
                          height: 64,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                width: 2.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ),
                          // color: Theme.of(context).colorScheme.onPrimary,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _sidebar = !_sidebar;
                                    if (size < 600) {
                                      _appBar = !_appBar;
                                    }
                                  });
                                },
                                icon: Icon(Icons.list),
                              ),
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
                                      onSaved: (item) =>
                                          app.addOrUpdateItem(item),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      : null,

                  // Content
                  Expanded(
                    child: Consumer<AppState>(
                      builder: (context, s, _) {
                        if (s.items.isEmpty) {
                          return Center(
                            child: Text(
                              'No items. Click "Add item" to create one.',
                            ),
                          );
                        }
                        return GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
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
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ItemDetailPage(item: it),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      Expanded(child: PreviewWidget(item: it)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              it.title,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                            ),
                                            SizedBox(height: 8),
                                            Text('Type: ${it.type}'),
                                            Spacer(),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          ItemEditorDialog(
                                                            categoryId:
                                                                it.categoryId,
                                                            item: it,
                                                            onSaved: (newItem) =>
                                                                s.addOrUpdateItem(
                                                                  newItem,
                                                                ),
                                                          ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.delete_outline,
                                                  ),
                                                  onPressed: () async {
                                                    final ok = await showDialog<bool>(
                                                      context: context,
                                                      builder: (ctx) => AlertDialog(
                                                        title: Text(
                                                          'Delete item?',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  false,
                                                                ),
                                                            child: Text(
                                                              'Cancel',
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  ctx,
                                                                  true,
                                                                ),
                                                            child: Text(
                                                              'Delete',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                    if (ok == true)
                                                      s.deleteItem(it.id!);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
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
      ),
    );
  }
}

Future<String?> _showTextDialog(
  BuildContext context, {
  required String title,
}) async {
  final _controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: TextField(controller: _controller, autofocus: true),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, _controller.text),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
