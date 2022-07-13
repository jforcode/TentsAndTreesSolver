import 'package:flutter/material.dart';
import 'package:trees_and_tents_solver/grid_view.dart';
import 'package:trees_and_tents_solver/home.dart';

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
        '/gridInput': (context) => const GridInputView(),
      },
      home: const HomeView(),
    );
  }
}
