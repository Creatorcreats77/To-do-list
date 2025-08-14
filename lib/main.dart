
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'features/home/data/datasources/db_helper.dart';
import 'features/home/presentation/pages/home_page.dart';

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
