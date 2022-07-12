import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:trees_and_tents_solver/solver.dart';

void main() {
  Future<SolverInput> _parseInputFromFile(String fileName) async {
    final file = File("test_solver_inputs/$fileName");
    var lines = await file.readAsLines();
    int n = int.parse(lines[0]);
    assert(n > 0);
    int m = int.parse(lines[1]);
    assert(m > 0);
    List<int> nTents = lines[2].split(" ").map<int>((e) => int.parse(e)).toList();
    assert(nTents.length == n);
    List<int> mTents = lines[3].split(" ").map<int>((e) => int.parse(e)).toList();
    assert(mTents.length == m);

    List<List<bool>> trees = [];
    for (int i = 0; i < n; i++) {
      var col = lines[i + 4].split(" ").map<bool>((e) => int.parse(e) == 1).toList();
      assert(col.length == m);
      trees.add(col);
    }
    assert(trees.length == n);

    return SolverInput(numRows: n, numCols: m, rowTents: nTents, colTents: mTents, grid: trees);
  }

  Future<List<List<ElementState>>> _parseOutputFromFile(String fileName) async {
    final file = File("test_solver_outputs/$fileName");
    var lines = await file.readAsLines();
    int n = int.parse(lines[0]);
    int m = int.parse(lines[1]);

    List<List<ElementState>> ret = [];
    for (int i = 0; i < n; i++) {
      var col = lines[i + 2].split(" ").map<ElementState>((e) {
        var eI = int.parse(e);
        if (eI == 1) return ElementState.tree;
        if (eI == 2) return ElementState.tent;
        return ElementState.grass;
      }).toList();
      assert(col.length == m);
      ret.add(col);
    }

    return ret;
  }

  group('sample inputs', () {
    var files = ['2X2', '5X5', '6X6', '8X8'];
    for (int fi = 0; fi < files.length; fi++) {
      test(files[fi], () async {
        var fileName = "${files[fi]}.txt";
        var input = await _parseInputFromFile(fileName);
        var output = await _parseOutputFromFile(fileName);

        final solver = Solver(input);
        var actualOutput = solver.solve();
        expect(actualOutput, output);
      });
    }
  });

  test('guess input', () async {
    var fileName = "8X8.txt";
    var input = await _parseInputFromFile(fileName);
    // var output = await _parseOutputFromFile(fileName);

    final solver = Solver(input);
    var actualOutput = solver.solve();
    print(actualOutput);
  });
}
