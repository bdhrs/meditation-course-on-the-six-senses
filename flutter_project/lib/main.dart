import 'package:flutter/material.dart';
import 'package:flutter_project/home.dart';
import 'package:flutter_project/md_importer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Markdown Viewer')),
        body: MdImporter(filePath: 'assets/md/test.md'),
      ),
    );
  }
}
