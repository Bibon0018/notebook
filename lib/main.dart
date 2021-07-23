import 'package:flutter_application_6/ok/kk.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter<NoteModel>(NoteModelAdapter());
  await Hive.openBox('ok');
  runApp(MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.grey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
        '/Home': (context) => FirstScreen(),
      }));
}
