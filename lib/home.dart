import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final _formKey = GlobalKey<FormState>();
  int groupValue = 0;
  TextEditingController rowTextCtrl = TextEditingController();
  TextEditingController colTextCtrl = TextEditingController();
  final maxSizeForGridInput = 15;
  final maxSizeForTextInput = 100;

  @override
  Widget build(BuildContext context) {
    rowTextCtrl.text = "5";
    colTextCtrl.text = "5";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Trees and tents solver"),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16),
              const Text(
                "Generate grid",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child: TextFormField(
                      controller: rowTextCtrl,
                      validator: _validate,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Row size',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 2.3,
                    child: TextFormField(
                      controller: colTextCtrl,
                      validator: _validate,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Column size',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Container(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Grid view with tap input"),
                leading: Radio(value: 0, groupValue: groupValue, onChanged: _setRadioValue),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text("Text based input"),
                leading: Radio(value: 1, groupValue: groupValue, onChanged: _setRadioValue),
              ),
              Container(height: 48),
              Container(
                margin: const EdgeInsets.only(top: 16),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _generate,
                  child: const Text("Input Grid"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generate() {
    if (_formKey.currentState!.validate()) {
      if (groupValue == 0) {
        Navigator.of(context).pushNamed(
          '/inputGrid',
          arguments: [int.parse(rowTextCtrl.text), int.parse(colTextCtrl.text)],
        );
      } else {
        Navigator.of(context).pushNamed(
          '/inputText',
          arguments: [int.parse(rowTextCtrl.text), int.parse(colTextCtrl.text)],
        );
      }
    }
  }

  String? _validate(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter a valid number";
    }
    int intValue = int.parse(value);
    if (groupValue == 0) {
      if (intValue > maxSizeForGridInput) {
        return "Max size for grid input is $maxSizeForGridInput";
      }
    } else {
      if (intValue > maxSizeForTextInput) {
        return "Max size for text input is $maxSizeForTextInput";
      }
    }

    return null;
  }

  void _setRadioValue(int? newValue) {
    setState(() {
      groupValue = newValue ?? 0;
    });
  }
}
