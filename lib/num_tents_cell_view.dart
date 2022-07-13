import 'package:flutter/material.dart';

class NumTentsCellView extends StatefulWidget {
  const NumTentsCellView({
    Key? key,
    required this.onValueUpdated,
    required this.isEditable,
    required this.fontSize,
  }) : super(key: key);

  final double fontSize;
  final bool isEditable;
  final Function(int newValue) onValueUpdated;

  @override
  State<StatefulWidget> createState() => NumTentsCellViewState();
}

class NumTentsCellViewState extends State<NumTentsCellView> {
  int currValue = 0;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (!widget.isEditable) {
          return;
        }

        setState(() {
          currValue++;
          widget.onValueUpdated(currValue);
        });
      },
      onLongPress: () {
        if (!widget.isEditable) {
          return;
        }

        setState(() {
          currValue = 0;
          widget.onValueUpdated(currValue);
        });
      },
      child: Text(
        "$currValue",
        style: TextStyle(fontSize: widget.fontSize, color: Colors.black54),
      ),
    );
  }
}
