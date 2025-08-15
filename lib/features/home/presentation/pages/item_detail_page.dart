import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';

import '../../../../main.dart';
import '../../data/models/item_model.dart';
import '../widgets/prewiev_widget.dart';

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
              // child: HighlightView(
              //   item.code.isEmpty ? '// No code provided' : item.code,
              //   language: 'dart',
              //   theme: githubTheme,
              //   padding: EdgeInsets.all(12),
              //   textStyle: TextStyle(fontFamily: 'monospace', fontSize: 13),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}