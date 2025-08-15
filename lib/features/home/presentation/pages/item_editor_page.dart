import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/datasources/db_helper.dart';
import '../../data/models/item_model.dart';

class ItemEditorDialog extends StatefulWidget {
  final int categoryId;
  final ItemModel? item;
  final int? isDone;

  ItemEditorDialog({required this.categoryId, this.item, this.isDone});

  @override
  _ItemEditorDialogState createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();


  String _title ='';
  String _text = '';

  // late int _isDone = 0;

  @override
  void initState() {
    super.initState();

  }

  void saveData()  {
    _title = _titleController.text.trim();
    _text = _textController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    return AlertDialog(
      title: Text(widget.item == null ? 'New item' : 'Edit item'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _textController,
              decoration: InputDecoration(labelText: 'Text'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            print("titleeeeeeee: $_title");
            final now = DateTime.now().toIso8601String();
            saveData();
            final newItem = ItemModel(
              id: widget.item?.id,
              categoryId: widget.categoryId,
              title: _title,
              text: _text,
              isDone: widget.isDone,
              createdAt: widget.item?.createdAt ?? now,
            );
            app.addOrUpdateItem(newItem);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
