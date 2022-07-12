import 'package:flutter/material.dart';
import 'package:trees_and_tents_solver/home.dart';

import 'grid_input_view.dart';
import 'text_input_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trees And Tents Solver',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/inputGrid': (context) => const GridInputView(),
        '/inputText': (context) => const TextInputView(),
      },
      home: const HomeView(),
    );
  }
}
