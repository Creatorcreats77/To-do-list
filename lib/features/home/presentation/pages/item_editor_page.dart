import 'package:flutter/material.dart';

import '../../data/models/item_model.dart';

class ItemEditorDialog extends StatefulWidget {
  final int categoryId;
  final ItemModel? item;
  final Future<void> Function(ItemModel) onSaved;
  ItemEditorDialog({required this.categoryId, this.item, required this.onSaved});
  @override
  _ItemEditorDialogState createState() => _ItemEditorDialogState();
}

class _ItemEditorDialogState extends State<ItemEditorDialog> {
  // final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _text;
  // late int _isDone = 0;

  @override
  void initState() {
    super.initState();
    _title = widget.item?.title ?? '';
    _text = widget.item?.text ?? '';
    // _isDone = widget.item?.isDone ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null ? 'New item' : 'Edit item'),
      content: SingleChildScrollView(
        child: Column(
            children: [
              TextFormField(initialValue: _title, decoration: InputDecoration(labelText: 'Title'), onSaved: (v) => _title = v ?? ''),
              SizedBox(height: 8),
              TextFormField(initialValue: _text, decoration: InputDecoration(labelText: 'Text'), onSaved: (v) => _text = v ?? ''),
            ],
          ),
        ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () async {
            print("titleeeeeeee: $_title");
            final now = DateTime.now().toIso8601String();
            final newItem = ItemModel(
              id: widget.item?.id,
              categoryId: widget.categoryId,
              title: _title,
              text: _text,
              createdAt: widget.item?.createdAt ?? now,
            );
            await widget.onSaved(newItem);
            print("New Item is this : $newItem");
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}