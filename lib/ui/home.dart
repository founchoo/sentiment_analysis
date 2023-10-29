import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ml_algo/ml_algo.dart';
import 'package:sentiment_analysis/algo/core.dart';
import 'package:sentiment_analysis/constant/solution.dart';
import 'package:sentiment_analysis/util/list_space_between_extension.dart';

Core core = Core(NormalOffensiveSolution());
KnnClassifier? model;

enum Selection { comments, news }

class HomePage extends StatefulWidget {
  final Function(bool, String) callback;

  HomePage({required this.callback, super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();
  String? _result;
  final _statesController = MaterialStatesController();
  Selection selection = Selection.comments;
  static const headerStyle =
      TextStyle(fontSize: 14, fontWeight: FontWeight.bold);
  static const sizedBox = SizedBox(height: 5);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  Future<void> changeSelection(Set<Selection> newSelection) async {
    setState(() {
      selection = newSelection.first;
      _statesController.update(MaterialState.disabled, true);
    });
    switch (selection) {
      case Selection.comments:
        core.solution = NormalOffensiveSolution();
      case Selection.news:
        core.solution = RealFakeSolution();
    }
    widget.callback(true, 'Model is loading...');
    model = await compute((Core c) async => await c.loadModel(), core);
    if (model == null) {
      throw Exception('Model is not found, please build model first!');
    }

    widget.callback(false, '');
    setState(() {
      if (model != null) {
        _statesController.update(MaterialState.disabled, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Select model category',
          style: headerStyle,
        ),
        SegmentedButton<Selection>(
          segments: const <ButtonSegment<Selection>>[
            ButtonSegment<Selection>(
                value: Selection.comments,
                label: Text('Comments'),
                icon: Icon(Icons.comment)),
            ButtonSegment<Selection>(
                value: Selection.news,
                label: Text('News'),
                icon: Icon(Icons.newspaper)),
          ],
          selected: <Selection>{selection},
          onSelectionChanged: (Set<Selection> newSelection) async {
            await changeSelection(newSelection);
          },
        ),
        sizedBox,
        const Text('Train dataset', style: headerStyle),
        FilledButton(
            onPressed: () async {
              widget.callback(true, 'Model is building...');

              var dataFrame = await core.loadData();
              dataFrame = await core.preProcessData(dataFrame);
              model = await core.buildModel(dataFrame);
              await core.saveModel(model!);

              widget.callback(false, '');
            },
            child: const Text('Build model')),
        sizedBox,
        const Text('Predict', style: headerStyle),
        Expanded(
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter something to predict',
            ),
            controller: myController,
            maxLines: null,
          ),
        ),
        FilledButton(
            statesController: _statesController,
            onPressed: () async {
              widget.callback(true, 'Predicting...');

              // Use code below to read model
              final result = await core.predictOne(model!, myController.text);

              widget.callback(false, '');

              setState(() {
                _result = result;
              });
            },
            child: const Text("Predict")),
        _result == null
            ? const Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text("Result will be displayed here"),
                ),
              )
            : Column(
                children: [
                  Card(
                    child: ListTile(
                        leading: const Icon(Icons.numbers_outlined),
                        title: const Text("Result"),
                        subtitle: Text("$_result")),
                  ),
                ],
              ),
      ].withSpaceBetween(height: 10),
    );
  }
}
