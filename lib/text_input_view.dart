import 'package:flutter/material.dart';

class TextInputView extends StatefulWidget {
  const TextInputView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TextInputViewState();
}

class TextInputViewState extends State<TextInputView> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List<int>;
    int row = args[0];
    int col = args[1];

    return Scaffold(
      appBar: AppBar(
        title: Text("Text based input $row X $col"),
      ),
      body: Container(),
    );
  }
}
