import 'package:flutter/material.dart';
import 'package:sentiment_analysis/algo/core.dart';
import 'package:sentiment_analysis/algo/extension/data_frame_extension.dart';
import 'package:sentiment_analysis/algo/extension/decision_tree_classifier_extension.dart';
import 'package:sentiment_analysis/ui/extension/list_space_between_extension.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myController = TextEditingController();
  String? _result;
  Core core = Core();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter something to analyze',
          ),
          controller: myController,
        ),
        FilledButton(
            onPressed: () async {
              // Use code below to build model
              (await (await core.loadData()).preProcessData()).buildModel();

              // Use code below to read model
              final result = await ((await core.loadModel())
                  .predictOne(myController.text));

              setState(() {
                _result = result;
              });
            },
            child: const Text("Analyze")),
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
      ].withSpaceBetween(height: 16),
    );
  }
}
