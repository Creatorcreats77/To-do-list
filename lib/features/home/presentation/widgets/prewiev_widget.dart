import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/item_model.dart';

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