import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomeViewState();
}

class HomeViewState extends State<HomeView> {
  final maxGridSize = 15.0;
  final minGridSize = 5.0;
  double currGridSize = 5.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trees and tents solver"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 8),
            Text(
              "Grid Size: (${currGridSize ~/ 1} X ${currGridSize ~/ 1})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Slider(
              max: maxGridSize,
              min: minGridSize,
              divisions: (maxGridSize - minGridSize) ~/ 1,
              value: currGridSize,
              onChanged: (newValue) {
                setState(() {
                  currGridSize = newValue;
                });
              },
            ),
            Container(height: 16),
            // TODO: can have video based instructions by screen captures. or a list of images which show tap interaction.
            const Text(
              "Instructions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Container(height: 8),
            const Text(
                "Tap on a number cell to increase value.\n"
                "Long press on a number cell to reset to 0.\n\n"
                "Tap on a grid cell to mark/unmark it as a tent.",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _generate,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }

  // TODO
  void _generateListInput() {
    // for bigger grids, a visual input won't be enough
    // so, add some sort of input mechanism for that
    // also other stuff like visualisation of solving has to be thought for that.
  }

  // TODO
  void _generateMidSizeUI() {
    // try to increase max size from 15 to 25
  }

  void _generate() {
    Navigator.of(context)
        .pushNamed('/gridInput', arguments: [currGridSize ~/ 1, currGridSize ~/ 1]);
  }
}
