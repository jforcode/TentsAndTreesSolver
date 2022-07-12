import 'dart:core';

/*

1. wherever the number of trees is equal to the number marked in row or column, mark the whole row as grass
2. tents can only be placed orthogonally to trees, mark any cell which is not orthogonal to tree as grass
3. each tree needs a tent. wherever there is only one available cell around the tree, mark a tent
4. tents can't be adjacent to each other in any direction. while marking a tent, mark the adjacent cells as grass

some other strategies
- block strategies - if the number of blocks/islands is equal to the number of tents left, and if any of the blocks
have single cells, mark them as tents.
  - 1, 2, 3 is not three blocks, it has space for 4 tents.

- consider trees grouped together. Because of the restrictions, the tent placement can be determined. at a later stage.

*/

class Solver {
  late SolverInput _input;
  late List<List<ElementState>> _grid;
  late List<Cell> _trees;
  late List<int> _completedTentsInRows;
  late List<int> _completedTentsInCols;
  late List<Cell> _changes;

  final orthogonalRs = [-1, 0, 1, 0];
  final orthogonalCs = [0, 1, 0, -1];
  final adjacentRs = [-1, -1, -1, 0, 1, 1, 1, 0];
  final adjacentCs = [-1, 0, 1, 1, 1, 0, -1, -1];

  Solver(SolverInput input) {
    _input = input;
    _grid = _convertInputToGrid(_input.grid);
    _trees = [];
    _completedTentsInRows = input.rowTents.map((e) => 0).toList();
    _completedTentsInCols = input.colTents.map((e) => 0).toList();
    _changes = [];

    _loopOverGrid((cell) {
      if (cell.element == ElementState.tree) {
        _trees.add(cell);
      }
    });
  }

  void _printGrid() {
    for (int i = 0; i < _input.numRows; i++) {
      print(_grid[i].map<String>((e) {
        switch (e) {
          case ElementState.none:
            return "-";
          case ElementState.tree:
            return "1";
          case ElementState.tent:
            return "2";
          case ElementState.grass:
            return "0";
        }
      }));
    }
    print("");
  }

  void _loopOverGrid(Function(Cell cell) action) {
    for (int i = 0; i < _input.numRows; i++) {
      for (int j = 0; j < _input.numCols; j++) {
        action(Cell(rowIndex: i, colIndex: j, element: _grid[i][j]));
      }
    }
  }

  void _loopOverOrthogonalCells(int r, int c, Function(Cell cell) action) {
    for (int i = 0; i < orthogonalRs.length; i++) {
      int r1 = r + orthogonalRs[i];
      int c1 = c + orthogonalCs[i];

      if (_validPos(r1, c1)) {
        action(Cell(rowIndex: r1, colIndex: c1, element: _grid[r1][c1]));
      }
    }
  }

  void _loopOverAdjacentCells(int r, int c, Function(Cell cell) action) {
    for (int i = 0; i < adjacentRs.length; i++) {
      int r1 = r + adjacentRs[i];
      int c1 = c + adjacentCs[i];

      if (_validPos(r1, c1)) {
        action(Cell(rowIndex: r1, colIndex: c1, element: _grid[r1][c1]));
      }
    }
  }

  List<List<ElementState>> _convertInputToGrid(List<List<bool>> trees) {
    return trees
        .map<List<ElementState>>((row) =>
            row.map<ElementState>((e) => e ? ElementState.tree : ElementState.none).toList())
        .toList();
  }

  List<List<ElementState>> solve() {
    // so that it doesn't become an infinite loop in testing
    int numTries = 0;

    do {
      try {
        print("Try number $numTries");
        _markAbsoluteValues();
        var probableTent = _getProbableTentLocation();
        print("Guessing $probableTent");

        if (probableTent == null) {
          if (_puzzleSolved()) {
            return _grid;
          } else {
            // there is no spot left for a tent, but the puzzle is still not solved.
            throw InvalidStateException.noMoreGuesses();
          }
        } else {
          _markTent(probableTent.rowIndex, probableTent.colIndex);
        }
      } on InvalidStateException catch (e) {
        print("Exception $e");

        _rollbackToLastGuessedTent();
      }
    } while (!_puzzleSolved() && numTries++ < 10);

    return _grid;
  }

  bool _puzzleSolved() {
    for (int i = 0; i < _input.numRows; i++) {
      if (_input.rowTents[i] != _completedTentsInRows[i]) {
        return false;
      }
    }
    for (int i = 0; i < _input.numCols; i++) {
      if (_input.colTents[i] != _completedTentsInCols[i]) {
        return false;
      }
    }
    return true;
  }

  void _rollbackToLastGuessedTent() {
    for (int i = _changes.length - 1; i >= 0; i--) {
      var cell = _changes[i];
      _grid[cell.rowIndex][cell.colIndex] = ElementState.none;
      _changes.removeAt(i);

      if (cell.element == ElementState.tent) {
        break;
      }
    }
  }

  Cell? _getProbableTentLocation() {
    for (int i = 0; i < _input.numRows; i++) {
      for (int j = 0; j < _input.numCols; j++) {
        if (_grid[i][j] == ElementState.none) {
          return Cell(rowIndex: i, colIndex: j, element: _grid[i][j]);
        }
      }
    }

    return null;
  }

  // this is a loop which marks all 100% confident values in the current state of grid
  void _markAbsoluteValues() {
    bool markedSomeCell = false;
    int i = 0;
    do {
      print("Marking absolutes ${i++}");

      _markFilledRowsAndColsAsGrass();
      _markNonAdjacentToTentAsGrass();
      markedSomeCell = _markAnOnlySpotNextToTreeAsTent();
      markedSomeCell |= _markTentsBasedOnIslands();

      _printGrid();
    } while (markedSomeCell);
  }

  // if the number of trees required in a row or column is satisfied, mark the remaining columns as grass
  void _markFilledRowsAndColsAsGrass() {
    for (int i = 0; i < _input.numRows; i++) {
      if (_input.rowTents[i] == _completedTentsInRows[i]) {
        _markRowAsGrass(i);
      }
    }

    // if 0 tents in a column, mark them as grass
    for (int i = 0; i < _input.numCols; i++) {
      if (_input.colTents[i] == _completedTentsInCols[i]) {
        _markColAsGrass(i);
      }
    }
  }

  // tents can only be orthogonal to trees
  void _markNonAdjacentToTentAsGrass() {
    _loopOverGrid((cell) {
      if (cell.element == ElementState.none &&
          !_hasTreeInOrthogonalCells(cell.rowIndex, cell.colIndex)) {
        _grid[cell.rowIndex][cell.colIndex] = ElementState.grass;
        _changes.add(
          Cell(rowIndex: cell.rowIndex, colIndex: cell.colIndex, element: ElementState.grass),
        );
      }
    });
  }

  // any trees where there is only one available spot next to them must have a tent there
  bool _markAnOnlySpotNextToTreeAsTent() {
    bool markedSomeCell = false;
    for (var cell in _trees) {
      Cell? available = _onlyAvailableCellNextToTree(cell.rowIndex, cell.colIndex);
      if (available != null) {
        _markTent(available.rowIndex, available.colIndex);
        markedSomeCell = true;
      }
    }

    return markedSomeCell;
  }

  List<Cell> _getMarkableCellsBasedOnIslandsInList(int tentsRequired, List<Cell> line) {
    List<Cell> toBeMarked = [];
    int islandCount = 0;

    for (int i = 0; i < line.length; i++) {
      if (line[i].element == ElementState.none) {
        islandCount++;
      } else {
        if (islandCount > 2) {
          return [];
        }

        if (islandCount == 1) {
          tentsRequired--;
          toBeMarked.add(line[i - 1]);
        } else if (islandCount == 2) {
          tentsRequired--;
        }

        islandCount = 0;
      }
    }

    if (islandCount > 2) {
      return [];
    }

    if (islandCount == 1) {
      tentsRequired--;
      toBeMarked.add(line[line.length - 1]);
    } else if (islandCount == 2) {
      tentsRequired--;
    }

    if (tentsRequired == 0) {
      return toBeMarked;
    } else if (tentsRequired > 0) {
      // less islands than tents
      throw InvalidStateException.invalidIslands();
    } else {
      // more islands than tents, valid state, but can't mark any cell
      return [];
    }
  }

  bool _markTentsBasedOnIslands() {
    bool markedSomeCell = false;
    for (int i = 0; i < _input.numRows; i++) {
      var requiredTents = _input.rowTents[i] - _completedTentsInRows[i];
      var col = <Cell>[];
      for (int j = 0; j < _input.numCols; j++) {
        col.add(Cell(rowIndex: i, colIndex: j, element: _grid[i][j]));
      }

      var toMarkList = _getMarkableCellsBasedOnIslandsInList(requiredTents, col);
      for (var toMark in toMarkList) {
        _markTent(toMark.rowIndex, toMark.colIndex);
      }

      markedSomeCell |= toMarkList.isNotEmpty;
    }

    for (int i = 0; i < _input.numCols; i++) {
      var requiredTents = _input.colTents[i] - _completedTentsInCols[i];
      var row = <Cell>[];
      for (int j = 0; j < _input.numRows; j++) {
        row.add(Cell(rowIndex: j, colIndex: i, element: _grid[j][i]));
      }

      // this throws invalid state exception, which we let the parent handle
      var toMarkList = _getMarkableCellsBasedOnIslandsInList(requiredTents, row);
      for (var toMark in toMarkList) {
        _markTent(toMark.rowIndex, toMark.colIndex);
      }

      markedSomeCell |= toMarkList.isNotEmpty;
    }

    return markedSomeCell;
  }

  void _markTent(int r, int c) {
    bool hasAdjacentTent = false;
    Cell? adjacentTent;
    List<Cell> adjacentNones = [];

    _loopOverAdjacentCells(r, c, (cell) {
      if (cell.element == ElementState.tent) {
        hasAdjacentTent = true;
        adjacentTent = cell;
      } else if (cell.element == ElementState.none) {
        adjacentNones.add(cell);
      }
    });

    if (hasAdjacentTent) {
      throw InvalidStateException.invalidTentMarking(
          Cell(rowIndex: r, colIndex: c, element: _grid[r][c]), adjacentTent!);
    }

    _grid[r][c] = ElementState.tent;
    _changes.add(Cell(rowIndex: r, colIndex: c, element: ElementState.tent));

    _completedTentsInRows[r]++;
    _completedTentsInCols[c]++;

    for (var adjNone in adjacentNones) {
      _grid[adjNone.rowIndex][adjNone.colIndex] = ElementState.grass;
      _changes.add(
        Cell(rowIndex: adjNone.rowIndex, colIndex: adjNone.colIndex, element: ElementState.grass),
      );
    }
  }

  Cell? _onlyAvailableCellNextToTree(int r, int c) {
    Cell? toRet;
    bool invalid = false;

    _loopOverOrthogonalCells(r, c, (cell) {
      if (cell.element == ElementState.tent) {
        invalid = true;
      }
      if (cell.element == ElementState.none) {
        if (toRet != null) {
          invalid = true;
        } else {
          toRet = cell;
        }
      }
    });

    return invalid ? null : toRet;
  }

  bool _hasTreeInOrthogonalCells(int r, int c) {
    bool ret = false;
    _loopOverOrthogonalCells(r, c, (cell) {
      if (cell.element == ElementState.tree) {
        ret = true;
      }
    });

    return ret;
  }

  bool _validPos(int r, int c) {
    return r >= 0 && r < _input.numRows && c >= 0 && c < _input.numCols;
  }

  void _markRowAsGrass(int rowIndex) {
    for (int i = 0; i < _input.numCols; i++) {
      if (_grid[rowIndex][i] == ElementState.none) {
        _grid[rowIndex][i] = ElementState.grass;
        _changes.add(Cell(rowIndex: rowIndex, colIndex: i, element: ElementState.grass));
      }
    }
  }

  void _markColAsGrass(int colIndex) {
    for (int i = 0; i < _input.numRows; i++) {
      if (_grid[i][colIndex] == ElementState.none) {
        _grid[i][colIndex] = ElementState.grass;
        _changes.add(Cell(rowIndex: i, colIndex: colIndex, element: ElementState.grass));
      }
    }
  }
}

class SolverInput {
  // the y axis
  int numRows;

  // the x axis
  int numCols;

  // y axis tents
  List<int> rowTents;

  // x axis tents
  List<int> colTents;

  // grid element true = tree present in cell
  List<List<bool>> grid;

  SolverInput({
    required this.numRows,
    required this.numCols,
    required this.rowTents,
    required this.colTents,
    required this.grid,
  });
}

class Cell {
  int rowIndex;
  int colIndex;
  ElementState element;

  Cell({
    required this.rowIndex,
    required this.colIndex,
    required this.element,
  });

  @override
  String toString() {
    return "Row: $rowIndex, Col: $colIndex, Element: $element";
  }
}

enum ElementState {
  none,
  tree,
  tent,
  grass,
}

class InvalidStateException implements Exception {
  String message = '';

  InvalidStateException.invalidTentMarking(Cell cellBeingMarked, Cell conflictCell) {
    message =
        "Invalid state while marking tent for cell $cellBeingMarked. Conflicting cell: $conflictCell";
  }

  InvalidStateException.invalidIslands() {
    message = "More tents present than islands.";
  }

  InvalidStateException.noMoreGuesses() {
    message = "No more guesses for tents, but the grid is unsolved";
  }

  @override
  String toString() {
    return message;
  }
}
