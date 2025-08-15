import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/item_model.dart';

class PreviewWidget extends StatelessWidget {
  final ItemModel item;
  const PreviewWidget({required this.item});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}