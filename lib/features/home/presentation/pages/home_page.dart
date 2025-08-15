import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/db_helper.dart';
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
                    width: size < 600 ? size : 260,
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
            ?_appBar
                ? Expanded(
                    child: Column(
                      children: [
                        // Top bar
                        Container(
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
                                  print(app.selectedCategoryId!);
                                  showDialog(
                                    context: context,
                                    builder: (_) => ItemEditorDialog(
                                      categoryId: app.selectedCategoryId!,
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
                                      maxCrossAxisExtent: size < 600
                                          ? size
                                          : 420,
                                      mainAxisExtent: 200,
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
                                          builder: (_) =>
                                              ItemDetailPage(item: it),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Top section: ID + Title with bottom divider
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  '${it.id}: ${it.title}',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                                ),
                                                Checkbox(
                                                  value: it.isDone == 0 ? false : true,
                                                  onChanged: (val) async {
                                                    s.updatingIsDone(it.id!, val == false ? 0 : 1);
                                                    print(
                                                      'Checkbox changed: $val',
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                            const Divider(thickness: 1.5),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'No description available jgchgcgv uiggyg iguiyguyguy iyuygjhg uyguygygy yuguyg iugu iuiug iuhu ohiuhui jkhjbkhghjgjhg iugiuyg iugiuyg iygiyug igy ig ',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodyMedium,
                                                  ),
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    IconButton(
                                                      tooltip: 'Edit',
                                                      icon: const Icon(
                                                        Icons.edit,
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              ItemEditorDialog(
                                                                categoryId: it
                                                                    .categoryId,
                                                                item: it,
                                                              ),
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      tooltip: 'Delete',
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                      ),
                                                      onPressed: () async {
                                                        final ok = await showDialog<bool>(
                                                          context: context,
                                                          builder: (ctx) => AlertDialog(
                                                            title: const Text(
                                                              'Delete item?',
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      ctx,
                                                                      false,
                                                                    ),
                                                                child:
                                                                    const Text(
                                                                      'Cancel',
                                                                    ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.pop(
                                                                      ctx,
                                                                      true,
                                                                    ),
                                                                child:
                                                                    const Text(
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

                                            // Middle section: description or extra text

                                            // Bottom right actions
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
                  )
                : null,
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
