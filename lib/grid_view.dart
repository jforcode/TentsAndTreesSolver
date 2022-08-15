import 'package:flutter/material.dart';
import 'package:trees_and_tents_solver/grid_cell_view.dart';
import 'package:trees_and_tents_solver/num_tents_cell_view.dart';
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
  double fontSize = 20;
  bool invalid = false;
  bool solved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reset();
    });
  }

  void reset() {
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

    fontSize = row > 12
        ? 8
        : row > 8
            ? 16
            : 20;
    editable = true;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Grid input $row X $col"),
      ),
      body: row == 0
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Column(
                  children: [
                    Container(height: 16),
                    _getGrid(),
                    Container(height: 16),
                    invalid
                        ? Text(
                            "Invalid Input",
                            style: TextStyle(color: Colors.red.shade700, fontSize: 20),
                          )
                        : Container(),
                  ],
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 16),
                  child: solved
                      ? ElevatedButton(onPressed: _goBack, child: const Text("HOME"))
                      : ElevatedButton(
                          onPressed: _solve,
                          child: const Text("SOLVE"),
                        ),
                )
              ],
            ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  void _solve() {
    setState(() {
      editable = false;
    });

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

    var output = Solver(input).solve();
    if (output == null) {
      setState(() {
        editable = true;
        invalid = true;
      });
    } else {
      setState(() {
        invalid = false;
        trees = output;
        solved = true;
      });
    }
  }

  Widget _getGrid() {
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
      children.add(SizedBox(
        width: cellWidth,
        height: cellWidth,
        child: NumTentsCellView(
          isEditable: editable,
          fontSize: fontSize,
          onValueUpdated: (newValue) {
            colTents[i] = newValue;
          },
        ),
      ));
    }

    for (int i = 0; i < row; i++) {
      children.add(SizedBox(
        width: cellWidth,
        height: cellWidth,
        child: NumTentsCellView(
          isEditable: editable,
          fontSize: fontSize,
          onValueUpdated: (newValue) {
            rowTents[i] = newValue;
          },
        ),
      ));

      for (int j = 0; j < col; j++) {
        children.add(SizedBox(
          width: cellWidth,
          height: cellWidth,
          child: GridCellView(
            key: UniqueKey(),
            value: trees[i][j],
            isEditable: editable,
            fontSize: fontSize,
            onValueUpdated: (newValue) {
              trees[i][j] = newValue;
            },
          ),
        ));
      }
    }

    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(right: 12),
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

  // TODO
  void _solveVisually() {
    // subscribe to changes
    // add the changes in a UI queue
    // every 1 second show a tent

    // this is needed mainly to show guesses in a big grid
    // guesses should be marked so in the incoming changes
    // exception should also be shown on UI. that's when we know a guess has failed
    // rollback should be also be shown differently.

    // so, will do this later if the app gains traction and feel like adding this feature.
  }

  // TODO
  void _saveSolved() {
    // save the solved grid locally.
    // can show the saved grids in the main menu as history.

    // not that important. can select a grid from history to tweak that.
  }

  // TODO
  void _statistics() {
    // save some statistics locally like how many grids of a particular size solved
    // time taken to solve
    // number of guesses needed

    // this can be used to improve the grid solving logic
  }

  // TODO
  void _saveCurrentState() {
    // save the input locally
    // on opening app, we can directly jump here with this in-progress input

    // convenience feature
  }
}
