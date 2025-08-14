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