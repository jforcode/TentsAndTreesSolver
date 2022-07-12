import 'package:flutter/material.dart';
import 'package:trees_and_tents_solver/solver.dart';

class GridInputView extends StatefulWidget {
  const GridInputView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GridInputViewState();
}

class GridInputViewState extends State<GridInputView> {
  int row = 0;
  int col = 0;
  List<int> rowTents = [];
  List<int> colTents = [];
  List<List<ElementState>> trees = [];
  bool editable = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as List<int>;
      row = args[0];
      col = args[1];
      for (int i = 0; i < row; i++) {
        rowTents.add(0);
      }
      for (int i = 0; i < col; i++) {
        colTents.add(0);
      }
      for (int i = 0; i < row; i++) {
        trees.add([]);
        for (int j = 0; j < col; j++) {
          trees[i].add(ElementState.none);
        }
      }

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grid based input $row X $col"),
      ),
      body: row == 0
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _getBody(),
                Container(height: 24),
                ElevatedButton(onPressed: _solve, child: const Text("SOLVE IN ONE SHOT")),
                ElevatedButton(onPressed: _solveVisually, child: const Text("SOLVE VISUALLY"))
              ],
            ),
    );
  }

  void _solve() {
    setState(() {
      editable = false;
    });

    print(trees[0]);

    SolverInput input = SolverInput(
      numRows: row,
      numCols: col,
      rowTents: rowTents,
      colTents: colTents,
      grid: trees
          .map<List<bool>>(
            (col) => col.map<bool>((e1) => e1 == ElementState.tree).toList(),
          )
          .toList(),
    );

    print(input.grid[0]);

    Solver s = Solver(input);
    trees = s.solve();
    setState(() {});
  }

  void _solveVisually() {}

  Widget _getBody() {
    var width = MediaQuery.of(context).size.width;
    var cellWidth = (width - 24 - col - 1) / (col + 1); // owing to margin and spacing
    var children = <Widget>[];

    // top left empty
    children.add(Container(
      width: cellWidth,
      height: cellWidth,
      color: Colors.transparent,
    ));

    for (int i = 0; i < col; i++) {
      children.add(Container(
        width: cellWidth,
        height: cellWidth,
        child: _getNumOfTentInputCell(false, i),
      ));
    }

    for (int i = 0; i < row; i++) {
      children.add(Container(
        width: cellWidth,
        height: cellWidth,
        child: _getNumOfTentInputCell(true, i),
      ));

      for (int j = 0; j < col; j++) {
        children.add(Container(
          width: cellWidth,
          height: cellWidth,
          child: _getCell(i, j),
        ));
      }
    }

    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: col + 1,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      children: children,
    );
  }

  Widget _getNumOfTentInputCell(bool isRow, int lineIndex) {
    return TextButton(
      onPressed: () {
        if (!editable) {
          return;
        }
        setState(() {
          if (isRow) {
            rowTents[lineIndex]++;
          } else {
            colTents[lineIndex]++;
          }
        });
      },
      onLongPress: () {
        if (!editable) {
          return;
        }
        setState(() {
          if (isRow) {
            rowTents[lineIndex] = 0;
          } else {
            colTents[lineIndex] = 0;
          }
        });
      },
      child: Text(
        isRow ? "${rowTents[lineIndex]}" : "${colTents[lineIndex]}",
        style: const TextStyle(fontSize: 24, color: Colors.black54),
      ),
    );
  }

  Widget _getCell(int rowIndex, int colIndex) {
    Color cellColor = Colors.transparent;
    String cellText = "";

    switch (trees[rowIndex][colIndex]) {
      case ElementState.none:
        cellColor = Colors.black87;
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

    return TextButton(
      onPressed: () {
        setState(() {
          if (!editable) {
            return;
          }

          trees[rowIndex][colIndex] = trees[rowIndex][colIndex] == ElementState.tree
              ? ElementState.none
              : ElementState.tree;
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(cellColor),
      ),
      child: Text(
        cellText,
        style: const TextStyle(color: Colors.black54, fontSize: 24),
      ),
    );
  }
}
