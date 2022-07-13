import 'package:flutter/material.dart';
import 'package:trees_and_tents_solver/solver.dart';

class GridCellView extends StatefulWidget {
  const GridCellView({
    Key? key,
    required this.value,
    required this.onValueUpdated,
    required this.isEditable,
    required this.fontSize,
  }) : super(key: key);

  final ElementState value;
  final double fontSize;
  final bool isEditable;
  final Function(ElementState newValue) onValueUpdated;

  @override
  State<StatefulWidget> createState() => GridCellViewState();
}

class GridCellViewState extends State<GridCellView> {
  ElementState currState = ElementState.none;

  @override
  void initState() {
    super.initState();
    setState(() {
      currState = widget.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color cellColor = Colors.transparent;
    String cellText = "";

    switch (currState) {
      case ElementState.none:
        cellColor = Colors.black54;
        cellText = "";
        break;
      case ElementState.tree:
        cellColor = Colors.green.shade300;
        cellText = "T";
        break;
      case ElementState.tent:
        cellColor = Colors.red.shade300;
        cellText = "X";
        break;
      case ElementState.grass:
        cellColor = Colors.lightGreen.shade300;
        cellText = "";
        break;
    }

    // each can be a stateful view in itself, then the whole state won't need to be changed
    return TextButton(
      onPressed: () {
        setState(() {
          if (!widget.isEditable) {
            return;
          }

          currState = currState == ElementState.tree ? ElementState.none : ElementState.tree;
          widget.onValueUpdated(currState);
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(cellColor),
      ),
      child: Text(
        cellText,
        style: TextStyle(color: Colors.black54, fontSize: widget.fontSize),
      ),
    );
  }
}
