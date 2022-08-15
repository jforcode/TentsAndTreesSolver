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
  final Image treeIcon =
      const Image(image: AssetImage('assets/icons/tree_icon.png'), fit: BoxFit.fitWidth);
  final Image tentIcon =
      const Image(image: AssetImage('assets/icons/tent_icon.png'), fit: BoxFit.fitWidth);

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
    Image? cellIcon;

    switch (currState) {
      case ElementState.none:
        cellColor = Colors.black54;
        break;
      case ElementState.tree:
        cellColor = Colors.green.shade300;
        cellIcon = treeIcon;
        break;
      case ElementState.tent:
        cellColor = Colors.red.shade200;
        cellIcon = tentIcon;
        break;
      case ElementState.grass:
        cellColor = Colors.lightGreen.shade300;
        break;
    }

    if (cellIcon == null) {
      return TextButton(
        onPressed: _onCellPressed,
        style: ButtonStyle(backgroundColor: MaterialStateProperty.all(cellColor)),
        child: const Text(""),
      );
    } else {
      return Container(
        color: cellColor,
        child: IconButton(
          onPressed: _onCellPressed,
          icon: cellIcon,
        ),
      );
    }
  }

  void _onCellPressed() {
    if (!widget.isEditable) {
      return;
    }

    setState(() {
      currState = currState == ElementState.tree ? ElementState.none : ElementState.tree;
      widget.onValueUpdated(currState);
    });
  }
}
